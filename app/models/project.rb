class Project < ActiveRecord::Base
  include SlackDomainable
  nilify_blanks
  attachment :image

  has_many :authentications, foreign_key: :slack_team_id
  has_many :accounts, through: :authentications

  has_many :award_types, inverse_of: :project, dependent: :destroy
  accepts_nested_attributes_for :award_types, reject_if: :invalid_params, allow_destroy: true

  has_many :awards, through: :award_types, dependent: :destroy
  has_many :contributors, through: :awards, source: :authentication

  belongs_to :owner_account, class_name: Account
  validates_presence_of :description, :owner_account, :slack_channel, :slack_team_name, :slack_team_id, :slack_team_image_34_url, :slack_team_image_132_url, :title
  validates_numericality_of :maximum_coins, greater_than: 0

  validate :valid_tracker_url, if: -> { tracker.present? }
  validate :valid_contributor_agreement_url, if: -> { contributor_agreement_url.present? }
  validate :valid_video_url, if: -> { video_url.present? }

  validate :maximum_coins_unchanged, if: -> { !new_record? }
  validate :valid_ethereum_enabled

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

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_params(attributes)
    AwardType.invalid_params(attributes)
  end

  def owner_slack_user_name
    owner_account.authentications.find_by(slack_team_id: slack_team_id)&.display_name
  end

  def description_paragraphs
    description.presence&.gsub(/\r/, '')&.split(/\n{2,}/) || []
  end

  def youtube_id
    # taken from http://stackoverflow.com/questions/5909121/converting-a-regular-youtube-link-into-an-embedded-video
    # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
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
      ethereum_enabled == true && ethereum_contract_address.blank?
    true
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
end
