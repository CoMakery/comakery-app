class Authentication < ActiveRecord::Base
  belongs_to :account
  has_many :projects, foreign_key: :slack_team_id, primary_key: :slack_team_id
  validates_presence_of :account, :provider, :slack_team_name, :slack_team_id, :slack_user_id, :slack_user_name, :slack_team_name

  def display_name
    return "#{slack_first_name} #{slack_last_name}" if slack_first_name.present? && slack_last_name.present?
    "@#{slack_user_name}"
  end

  def self.find_or_create_from_auth_hash!(auth_hash)
    slack_auth_hash = SlackAuthHash.new(auth_hash)

    account = Account.find_or_create_by(email: slack_auth_hash.email_address)

    # find the "slack" authentication *for the given slack user* if exists
    # note that we persist an authentication for every team
    authentication = Authentication.find_or_initialize_by(
      provider: slack_auth_hash.provider,
      slack_user_id: slack_auth_hash.slack_user_id,
      slack_team_id: slack_auth_hash.slack_team_id
    )
    authentication.update!(
      account_id: account.id,
      slack_user_name: slack_auth_hash.slack_user_name,
      slack_first_name: slack_auth_hash.slack_first_name,
      slack_last_name: slack_auth_hash.slack_last_name,
      slack_team_name: slack_auth_hash.slack_team_name,
      slack_token: slack_auth_hash.slack_token,
      slack_team_domain: slack_auth_hash.slack_team_domain
    )

    account
  end
end
