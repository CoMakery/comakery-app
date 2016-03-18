class Project < ActiveRecord::Base
  include SlackDomainable
  nilify_blanks
  attachment :image

  has_many :authentications, foreign_key: :slack_team_id
  has_many :accounts, through: :authentications

  has_many :award_types, inverse_of: :project, dependent: :destroy
  accepts_nested_attributes_for :award_types, reject_if: :invalid_params, allow_destroy: true

  has_many :awards, through: :award_types, dependent: :destroy

  belongs_to :owner_account, class_name: Account
  validates_presence_of :owner_account, :slack_channel, :slack_team_name, :slack_team_id, :slack_team_image_34_url, :slack_team_image_132_url, :title

  validate :valid_tracker_url, if: -> { tracker.present? }

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

  def self.public
    where(public: true)
  end

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_params(attributes)
    AwardType.invalid_params(attributes)
  end

  def owner_slack_user_name
    owner_account.slack_auth(slack_team_id: slack_team_id)&.display_name
  end

  private

  def valid_tracker_url
    uri = URI.parse(tracker || "")
    errors[:tracker] << "must be a valid url" unless uri.absolute?
  end
end
