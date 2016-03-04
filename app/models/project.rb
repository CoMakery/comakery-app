class Project < ActiveRecord::Base
  nilify_blanks
  attachment :image

  has_many :authentications, foreign_key: :slack_team_id
  has_many :accounts, through: :authentications

  has_many :reward_types, inverse_of: :project, dependent: :destroy
  accepts_nested_attributes_for :reward_types, reject_if: :invalid_params, allow_destroy: true

  has_many :rewards, through: :reward_types, dependent: :destroy

  belongs_to :owner_account, class_name: Account
  validates_presence_of :owner_account, :slack_team_name, :slack_team_id, :title

  validate :valid_tracker_url, if: ->{ tracker.present? }
  validate :valid_slack_team_domain

  def invalid_params(attributes)
    RewardType.invalid_params(attributes)
  end

  def owner_slack_user_name
    owner_account.slack_auth(slack_team_id: slack_team_id)&.display_name
  end

  private

  def valid_tracker_url
    uri = URI.parse(tracker || "")
    errors[:tracker] << "must be a valid url" unless uri.absolute?
  end

  def valid_slack_team_domain
    errors[:slack_team_domain] << "can't be blank" if slack_team_domain == ""

    unless slack_team_domain.nil? || slack_team_domain =~ /\A[a-z0-9][a-z0-9-]*\z/
      errors[:slack_team_domain] << "must only contain lower-case letters, numbers, and hyphens and start with a letter or number"
    end
  end
end
