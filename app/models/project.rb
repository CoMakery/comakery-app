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
  validates_presence_of :owner_account, :slack_team_name, :slack_team_id, :title

  validate :valid_tracker_url, if: ->{ tracker.present? }

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
