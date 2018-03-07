class Authentication < ApplicationRecord
  # include SlackDomainable

  belongs_to :account
  # has_many :projects, foreign_key: :slack_team_id, primary_key: :slack_team_id
  validates :account, :provider, :uid, presence: true

  #TODO update after refactor
  def slack_team_ethereum_enabled?
    allow_ethereum = Rails.application.config.allow_ethereum
    allowed_domains = allow_ethereum.to_s.split(',').compact
    # allowed_domains.include?(slack_team_domain)
    true
  end

  def self.find_with_omniauth(auth_hash)
    find_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
  end

  def self.create_with_omniauth!(auth_hash)
    account = Account.find_or_create_by!(email: auth_hash['info']['email']) do |a|
      a.first_name = auth_hash['info']['first_name']
      a.last_name = auth_hash['info']['last_name']
    end
    create(uid: auth_hash['uid'], provider: auth_hash['provider'],
           oauth_response: auth_hash, email: auth_hash['info']['email'],
           token: auth_hash['credentials']['token'],
           account: account)
    account
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
