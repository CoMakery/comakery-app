class Project < ActiveRecord::Base
  include SlackDomainable
  include EthereumAddressable

  nilify_blanks
  attachment :image

  has_many :authentications, foreign_key: :slack_team_id, primary_key: :slack_team_id
  has_many :accounts, through: :authentications

  has_many :award_types, inverse_of: :project, dependent: :destroy
  accepts_nested_attributes_for :award_types, reject_if: :invalid_params, allow_destroy: true

  has_many :awards, through: :award_types, dependent: :destroy

  has_many :payments, dependent: :destroy do
    def new_with_quantity(quantity_redeemed:, payee_auth:)
      project = @association.owner

      new(total_value: project.share_of_revenue_unpaid(quantity_redeemed),
          quantity_redeemed: quantity_redeemed,
          share_value: project.revenue_per_share,
          currency: project.denomination,
          payee: payee_auth).
          tap { |n| n.truncate_total_value_to_currency_precision }
    end

    def create_with_quantity(**attrs)
      new_with_quantity(**attrs).tap {|n| n.save }
    end
  end

  has_many :contributors, through: :awards, source: :authentication # TODO deprecate in favor of contributors_distinct
  has_many :contributors_distinct, -> { distinct }, through: :awards, source: :authentication
  has_many :revenues

  belongs_to :owner_account, class_name: Account

  enum payment_type: {
      revenue_share: 0,
      project_coin: 1
  }

  enum denomination: {
      USD: 0,
      BTC: 1,
      ETH: 2
  }

  validates_presence_of :description, :owner_account, :slack_channel, :slack_team_name, :slack_team_id,
                        :slack_team_image_34_url, :slack_team_image_132_url, :title, :legal_project_owner,
                        :denomination

  validates_presence_of :royalty_percentage, :maximum_royalties_per_month, unless: :project_coin?

  validates_numericality_of :maximum_coins, greater_than: 0
  validates_numericality_of :royalty_percentage, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true

  validate :valid_tracker_url, if: -> { tracker.present? }
  validate :valid_contributor_agreement_url, if: -> { contributor_agreement_url.present? }
  validate :valid_video_url, if: -> { video_url.present? }

  validate :maximum_coins_unchanged, if: -> { !new_record? }
  validate :valid_ethereum_enabled
  validates :ethereum_contract_address, ethereum_address: {type: :account, immutable: true} # see EthereumAddressable
  validate :denomination_changeable

  before_save :set_transitioned_to_ethereum_enabled

  def self.with_last_activity_at
    select(Project.column_names.map { |c| "projects.#{c}" }.<<("max(awards.created_at) as last_award_created_at").join(","))
        .joins("left join award_types on projects.id = award_types.project_id")
        .joins("left join awards on award_types.id = awards.award_type_id")
        .group("projects.id")
        .order("max(awards.created_at) desc nulls last, projects.created_at desc nulls last")
  end

  def self.for_account(account)
    where(slack_team_id: account&.slack_auth.slack_team_id)
  end

  def self.not_for_account(account)
    where.not(slack_team_id: account&.slack_auth.slack_team_id)
  end

  def self.public_projects
    where(public: true)
  end

  def total_revenue
    revenues.total_amount
  end

  def total_awarded
    awards.total_awarded
  end

  def total_awards_outstanding
    total_awarded - payments.sum(:quantity_redeemed)
  end

  # truncated to project currency precision
  # don't multiply this number
  def share_of_revenue_unpaid(awards)
    return BigDecimal(0) if royalty_percentage.blank? || total_revenue_shared == 0 || total_awarded == 0 || awards.blank?
    ((BigDecimal(awards) * total_revenue_shared_unpaid) / BigDecimal(total_awards_outstanding)).truncate(currency_precision)
  end

  def total_revenue_shared
    return BigDecimal(0) if royalty_percentage.blank? || project_coin?
    total_revenue * (royalty_percentage * BigDecimal('0.01'))
  end

  def total_revenue_shared_unpaid
    total_revenue_shared - payments.sum(:total_value)
  end

  # truncated to 8 decimal places
  # don't multiply this number
  def revenue_per_share
    return BigDecimal(0) if royalty_percentage.blank?|| total_awarded == 0
    (total_revenue_shared_unpaid / BigDecimal(total_awards_outstanding)).truncate(8)
  end

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_params(attributes)
    AwardType.invalid_params(attributes)
  end

  def owner_slack_user_name
    owner_account.authentications.find_by(slack_team_id: slack_team_id)&.display_name
  end

  def youtube_id
    # taken from http://stackoverflow.com/questions/5909121/converting-a-regular-youtube-link-into-an-embedded-video
    # Regex from http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
    if video_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      video_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end
    youtube_id
  end

  def transitioned_to_ethereum_enabled?
    !!@transitioned_to_ethereum_enabled
  end


  def share_revenue?
    revenue_share? && (royalty_percentage&.> 0)
  end

  def royalty_percentage=(x)
    x_truncated = BigDecimal(x, 14).truncate(13) unless x.blank?
    write_attribute(:royalty_percentage, x_truncated)
  end

  private

  def valid_tracker_url
    validate_url(:tracker)
  end

  def valid_contributor_agreement_url
    validate_url(:contributor_agreement_url)
  end

  def valid_video_url
    validate_url(:video_url)
    return if errors[:video_url].present?

    errors[:video_url] << "must be a Youtube link like 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'" unless youtube_id.present?
  end

  def valid_ethereum_enabled
    if ethereum_enabled_changed? && ethereum_enabled == false
      errors[:ethereum_enabled] << "cannot be set to false after it has been set to true"
    end
  end

  def set_transitioned_to_ethereum_enabled
    @transitioned_to_ethereum_enabled = ethereum_enabled_changed? &&
        ethereum_enabled && ethereum_contract_address.blank?
    true # don't halt filter
  end

  def validate_url(attribute_name)
    uri = URI.parse(self.send(attribute_name) || "")
  rescue URI::InvalidURIError
    uri = nil
  ensure
    errors[attribute_name] << "must be a valid url" unless uri&.absolute?
    uri
  end

  def maximum_coins_unchanged
    if maximum_coins_was > 0 and maximum_coins_was != maximum_coins
      errors[:maximum_coins] << "can't be changed"
    end
  end

  def denomination_changeable
    errors.add(:denomination, "cannot be changed because the license terms are finalized") if license_finalized_was
    errors.add(:denomination, "cannot be changed because revenue has been recorded") if revenues.any? && denomination_changed?
  end

  def currency_precision
    Comakery::Currency::PRECISION[denomination]
  end
end
