class Authentication < ActiveRecord::Base
  include SlackDomainable

  belongs_to :account
  has_many :projects, foreign_key: :slack_team_id, primary_key: :slack_team_id
  validates_presence_of :account, :provider, :slack_team_id, :slack_team_image_34_url, :slack_team_image_132_url, :slack_team_name, :slack_user_id, :slack_user_name

  def display_name
    if slack_first_name.present? || slack_last_name.present?
      [ slack_first_name.presence, slack_last_name.presence ].compact.join(' ')
    else
      "@#{slack_user_name}"
    end
  end

  def slack_icon
    slack_image_32_url || slack_team_image_34_url
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
      slack_image_32_url: slack_auth_hash.slack_image_32_url,
      slack_team_image_34_url: slack_auth_hash.slack_team_image_34_url,
      slack_team_image_132_url: slack_auth_hash.slack_team_image_132_url,
      slack_token: slack_auth_hash.slack_token,
      slack_team_domain: slack_auth_hash.slack_team_domain,
      oauth_response: auth_hash
    )

    # This will go away when we create a Team model <https://github.com/CoMakery/comakery-app/issues/113>
    Project.where(slack_team_id: slack_auth_hash.slack_team_id).update_all(
      slack_team_name: slack_auth_hash.slack_team_name,
      slack_team_image_34_url: slack_auth_hash.slack_team_image_34_url,
      slack_team_image_132_url: slack_auth_hash.slack_team_image_132_url,
      slack_team_domain: slack_auth_hash.slack_team_domain
    )

    account
  end
end
