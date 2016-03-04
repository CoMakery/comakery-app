class Reward < ActiveRecord::Base
  belongs_to :account
  belongs_to :issuer, class_name: Account
  belongs_to :reward_type

  validates_presence_of :account, :issuer, :reward_type

  def issuer_slack_user_name
    issuer.slack_auth(slack_team_id: slack_team_id)&.display_name
  end

  def recipient_slack_user_name
    account.slack_auth(slack_team_id: slack_team_id)&.display_name
  end

  private

  def slack_team_id
    reward_type.project.slack_team_id
  end
end
