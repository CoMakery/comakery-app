class Authentication < ApplicationRecord
  # include SlackDomainable

  belongs_to :account
  has_many :authentication_teams, dependent: :destroy
  validates :account, :provider, :uid, presence: true

  #TODO update after refactor
  def slack_team_ethereum_enabled?
    # allow_ethereum = Rails.application.config.allow_ethereum
    # allowed_domains = allow_ethereum.to_s.split(',').compact
    # allowed_domains.include?(slack_team_domain)
    true
  end

  def self.find_with_omniauth(auth_hash)
    authentication = find_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
    authentication.build_team auth_hash if authentication
    authentication
  end

  def self.create_with_omniauth!(auth_hash)
    account = Account.find_or_create_by!(email: auth_hash['info']['email']) do |a|
      a.first_name = auth_hash['info']['first_name']
      a.last_name = auth_hash['info']['last_name']
    end
    authentication = create(uid: auth_hash['uid'], provider: auth_hash['provider'],
           oauth_response: auth_hash, email: auth_hash['info']['email'],
           token: auth_hash['credentials']['token'],
           account: account)
    authentication.build_team auth_hash
    account
  end

  def build_team auth_hash
    return if auth_hash['info']['team_id'].blank?
    team = Team.find_or_create_by team_id: auth_hash['info']['team_id'] do |t|
      t.name = auth_hash['info']['team']
      t.domain = auth_hash['info']['team_domain']
      t.provider = auth_hash['provider']
      t.image = auth_hash.dig('extra', 'team_info', 'team', 'icon', 'image_132')
    end
    authentication_teams.find_or_create_by account_id: account.id, team_id: team.id
  end

  def self.find_or_create_from_auth_hash!(auth_hash)
    slack_auth_hash = SlackAuthHash.new(auth_hash)

    account = Account.find_or_create_by(email: slack_auth_hash.email_address)

    # find the "slack" authentication *for the given slack user* if exists
    # note that we persist an authentication for every team
    authentication = Authentication.find_or_initialize_by(
      provider: slack_auth_hash.provider,
      uid: slack_auth_hash.slack_user_id
    )
    authentication.update!(
      account_id: account.id,
      token: slack_auth_hash.slack_token,
      oauth_response: auth_hash
    )
    authentication.touch # we must change updated_at manually: update! does not change updated_at if attrs have not changed
    account.first_name = slack_auth_hash.slack_first_name if account.first_name.blank?
    account.last_name = slack_auth_hash.slack_last_name if account.last_name.blank?
    account.save!

    account
  end
end
