class Project < ApplicationRecord
  ROYALTY_PERCENTAGE_PRECISION = 13
  BLOCKCHAIN_NAMES = {
    erc20: 'ethereum',
    eth: 'ethereum',
    qrc20: 'qtum',
    ada: 'cardano',
    btc: 'bitcoin'
  }.freeze

  nilify_blanks
  attachment :image

  attachment :square_image, type: :image
  attachment :panoramic_image, type: :image

  belongs_to :account
  belongs_to :mission
  belongs_to :token
  has_many :award_types, inverse_of: :project, dependent: :destroy
  has_many :awards, through: :award_types, dependent: :destroy
  has_many :completed_awards, -> { where.not ethereum_transaction_address: nil }, through: :award_types, source: :awards
  has_many :channels, -> { order :created_at }, inverse_of: :project, dependent: :destroy

  has_many :payments, dependent: :destroy do
    def new_with_quantity(quantity_redeemed:, account:)
      project = @association.owner
      quantity = quantity_redeemed.blank? ? 0 : quantity_redeemed
      new(total_value: BigDecimal(quantity) * project.revenue_per_share,
          quantity_redeemed: quantity_redeemed,
          share_value: project.revenue_per_share,
          currency: project.token.denomination,
          account: account)
        .tap(&:truncate_total_value_to_currency_precision)
    end

    def create_with_quantity(**attrs)
      new_with_quantity(**attrs).tap(&:save)
    end
  end

  has_many :contributors, through: :awards, source: :account # TODO: deprecate in favor of contributors_distinct
  has_many :contributors_distinct, -> { distinct }, through: :awards, source: :account
  has_many :revenues
  has_many :teams, through: :account

  accepts_nested_attributes_for :award_types, reject_if: :invalid_params, allow_destroy: true
  accepts_nested_attributes_for :channels, reject_if: :invalid_channel, allow_destroy: true

  enum payment_type: {
    revenue_share: 0,
    project_token: 1
  }
  enum visibility: %i[member_unlisted member public_listed public_unlisted archived]
  enum status: %i[active passive]

  validates :description, :account, :title, :legal_project_owner, :token_id, presence: true
  validates :long_id, presence: { message: "identifier can't be blank" }
  validates :long_id, uniqueness: { message: "identifier can't be blank or not unique" }
  validates :royalty_percentage, :maximum_royalties_per_month, presence: { if: :revenue_share? }
  validates :maximum_tokens, numericality: { greater_than: 0 }
  validates :royalty_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validate :valid_tracker_url, if: -> { tracker.present? }
  validate :valid_contributor_agreement_url, if: -> { contributor_agreement_url.present? }
  validate :valid_video_url, if: -> { video_url.present? }
  validate :maximum_tokens_unchanged, if: -> { !new_record? }

  scope :featured, -> { order :featured }
  scope :unlisted, -> { where 'projects.visibility in(2,3)' }
  scope :listed, -> { where 'projects.visibility not in(2,3)' }
  scope :visible, -> { where 'projects.visibility not in(2,3,4)' }
  scope :unarchived, -> { where.not visibility: 4 }
  scope :publics, -> { where 'projects.visibility in(1,3)' }

  delegate :coin_type_token?, to: :token
  delegate :coin_type_on_ethereum?, to: :token
  delegate :coin_type_on_qtum?, to: :token
  delegate :coin_type_on_cardano?, to: :token
  delegate :coin_type_on_bitcoin?, to: :token
  delegate :transitioned_to_ethereum_enabled?, to: :token
  delegate :decimal_places_value, to: :token
  delegate :populate_token?, to: :token
  delegate :total_awarded, to: :awards

  def self.with_last_activity_at
    select(Project.column_names.map { |c| "projects.#{c}" }.<<('max(awards.created_at) as last_award_created_at').join(','))
      .joins('left join award_types on projects.id = award_types.project_id')
      .joins('left join awards on award_types.id = awards.award_type_id')
      .group('projects.id')
      .order('max(awards.created_at) desc nulls last, projects.created_at desc nulls last')
  end

  def top_contributors
    Account.select('accounts.*, sum(a1.total_amount) as total_awarded, max(a1.created_at) as last_awarded_at').joins("
      left join awards a1 on a1.account_id=accounts.id
      left join award_types on a1.award_type_id=award_types.id
      left join projects on award_types.project_id=projects.id")
           .where('projects.id=?', id)
           .group('accounts.id')
           .order('total_awarded desc, last_awarded_at desc').first(5)
  end

  def create_ethereum_awards!
    CreateEthereumAwards.call(awards: awards)
  end

  def total_revenue
    revenues.total_amount
  end

  def total_month_awarded
    awards.where('awards.created_at >= ?', Time.zone.today.beginning_of_month).sum(:total_amount)
  end

  def total_awards_outstanding
    total_awarded - total_awards_redeemed
  end

  def total_awards_redeemed
    payments.sum(:quantity_redeemed)
  end

  def share_of_revenue_unpaid(awards)
    return BigDecimal(0) if royalty_percentage.blank? || total_revenue_shared == 0 || total_awarded == 0 || awards.blank?
    (BigDecimal(awards) * revenue_per_share).truncate(token.currency_precision)
  end

  def total_revenue_shared
    return BigDecimal(0) if royalty_percentage.blank? || project_token?
    total_revenue * (royalty_percentage * BigDecimal('0.01'))
  end

  def total_paid_to_contributors
    payments.sum(:total_value)
  end

  def total_revenue_shared_unpaid
    total_revenue_shared - total_paid_to_contributors
  end

  # truncated to 8 decimal places
  def revenue_per_share
    return BigDecimal(0) if royalty_percentage.blank? || total_awarded == 0
    (total_revenue_shared_unpaid / BigDecimal(total_awards_outstanding)).truncate(8)
  end

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_params(attributes)
    AwardType.invalid_params(attributes)
  end

  def invalid_channel(attributes)
    Channel.invalid_params(attributes)
  end

  # def owner_slack_user_name
  #   account.authentications.find_by(slack_team_id: slack_team_id)&.display_name
  # end

  def video_id
    # taken from http://stackoverflow.com/questions/5909121/converting-a-regular-youtube-link-into-an-embedded-video
    # Regex from http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
    # Vimeo regex from https://stackoverflow.com/questions/41208456/javascript-regex-vimeo-id

    case video_url
    when /youtu\.be\/([^\?]*)/
      Regexp.last_match(1)
    when /^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/
      Regexp.last_match(5)
    when /(?:www\.|player\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|album\/(?:\d+)\/video\/|video\/|)(\d+)([a-zA-Z0-9_\-]*)?/i
      Regexp.last_match(1)
    end
  end

  def share_revenue?
    revenue_share? && (royalty_percentage&.> 0)
  end

  def show_id
    unlisted? ? long_id : id
  end

  def public?
    public_listed? || public_unlisted?
  end

  def unarchived?
    Project.unarchived.where(id: id).present?
  end

  def access_unlisted?(check_account)
    return true if public_unlisted?
    return true if member_unlisted? && check_account&.same_team_or_owned_project?(self)
  end

  def can_be_access?(check_account)
    return true if public? && !require_confidentiality?
    check_account && check_account.same_team_or_owned_project?(self)
  end

  def show_revenue_info?(account)
    share_revenue? && can_be_access?(account)
  end

  def unlisted?
    member_unlisted? || public_unlisted?
  end

  def royalty_percentage=(x)
    x_truncated = BigDecimal(x, ROYALTY_PERCENTAGE_PRECISION).truncate(ROYALTY_PERCENTAGE_PRECISION) if x.present?
    self[:royalty_percentage] = x_truncated
  end

  def percent_awarded
    total_awarded * 100.0 / maximum_tokens
  end

  def awards_for_chart(max: 1000)
    result = []
    recents = awards.limit(max).order('id desc')
    date_groups = recents.group_by { |a| a.created_at.strftime('%Y-%m-%d') }
    if awards.count > max
      date_groups.delete(recents.first.created_at.strftime('%Y-%m-%d'))
    end
    contributors = {}
    recents.map(&:account).uniq.each do |a|
      name = a&.decorate&.name || 'Others'
      contributors[name] = 0
    end
    date_groups.each do |group|
      item = {}
      item[:date] = group[0]
      item = item.merge(contributors)
      user_groups = group[1].group_by(&:account)
      user_groups.each do |ugroup|
        name = ugroup[0]&.decorate&.name || 'Others'
        item[name] = ugroup[1].sum(&:total_amount)
      end
      result << item
    end
    result
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

    errors[:video_url] << 'must be a link to Youtube or Vimeo video' if video_id.blank?
  end

  def validate_url(attribute_name)
    uri = URI.parse(send(attribute_name) || '')
  rescue URI::InvalidURIError
    uri = nil
  ensure
    errors[attribute_name] << 'must be a valid url' unless uri&.absolute?
    uri
  end

  def maximum_tokens_unchanged
    if maximum_tokens_was > 0 && maximum_tokens_was != maximum_tokens
      errors[:maximum_tokens] << "can't be changed" if license_finalized? || token.ethereum_enabled?
    end
  end
end
