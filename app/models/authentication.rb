class Authentication < ApplicationRecord

  belongs_to :account
  has_many :authentication_teams, dependent: :destroy
  validates :account, :provider, :uid, presence: true

  # TODO: update after refactor
  def slack_team_ethereum_enabled?
    # allow_ethereum = Rails.application.config.allow_ethereum
    # allowed_domains = allow_ethereum.to_s.split(',').compact
    # allowed_domains.include?(slack_team_domain)
    true
  end

  def self.find_with_omniauth(auth_hash)
    authentication = find_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
    if authentication
      authentication.update oauth_response: auth_hash, token: auth_hash['credentials']['token'] if auth_hash.present?
      authentication.build_team auth_hash
    end
    authentication
  end

  def self.create_with_omniauth!(auth_hash)
    account = Account.find_or_create_by!(email: auth_hash['info']['email']) do |a|
      a.first_name = auth_hash['info']['first_name']
      a.last_name = auth_hash['info']['last_name']
    end
    authentication = account.authentications.find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider']) do |a|
      a.oauth_response = auth_hash
      a.token = auth_hash['credentials']['token']
    end
    authentication.build_team auth_hash
    account
  rescue
    nil
  end

  def slack?
    provider == 'slack'
  end

  def discord?
    provider == 'discord'
  end

  def build_team(auth_hash)
    slack? ? build_slack_team(auth_hash) : build_discord_team
  end

  def build_slack_team(auth_hash)
    return if auth_hash['info']['team_id'].blank?
    team = Team.find_or_create_by team_id: auth_hash['info']['team_id'] do |t|
      t.name = auth_hash['info']['team']
      t.domain = auth_hash['info']['team_domain']
      t.provider = auth_hash['provider']
      t.image = auth_hash.dig('extra', 'team_info', 'team', 'icon', 'image_132')
    end
    team.build_authentication_team self
  end

  def build_discord_team
    discord = Comakery::Discord.new(token)
    discord.guilds.each do |guild|
      team = Team.find_or_create_by team_id: guild['id'] do |t|
        t.name = guild['name']
        t.provider = 'discord'
        t.image = guild['icon']
      end
      team.build_authentication_team self
    end
  end
end
