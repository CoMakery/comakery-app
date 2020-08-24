class Authentication < ApplicationRecord
  belongs_to :account
  has_many :authentication_teams, dependent: :destroy
  validates :account, :provider, :uid, presence: true

  def self.find_or_create_by_omniauth(auth_hash)
    authentication = find_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
    acc, authentication = process_authentication(authentication, auth_hash)

    acc&.update_columns agreed_to_user_agreement: Date.current if acc&.agreed_to_user_agreement.blank?
    authentication
  end

  def self.process_authentication(authentication, auth_hash)
    if authentication
      authentication.update_info auth_hash if authentication.confirmed?
      acc = authentication.account
    elsif auth_hash['info'] && auth_hash['info']['email'].present?
      acc = Account.find_or_create_by email: auth_hash['info']['email']

      authentication = acc.authentications.create(uid: auth_hash['uid'], provider: auth_hash['provider'], confirm_token: SecureRandom.hex, oauth_response: auth_hash)
    end
    [acc, authentication]
  end

  def update_info(auth_hash)
    return if auth_hash.blank?

    update_account auth_hash
    update oauth_response: auth_hash, token: auth_hash['credentials']['token']
    build_team auth_hash
  end

  def update_account(auth_hash)
    account.first_name = auth_hash['info']['first_name'] if account.first_name.blank?
    account.last_name = auth_hash['info']['last_name'] if account.last_name.blank?
    account.nickname = auth_hash['info']['name'] if account.nickname.blank?
    account.save
  end

  def slack?
    provider == 'slack'
  end

  def confirmed?
    confirm_token.blank?
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
      team.build_authentication_team self, manager?(guild['permissions'], guild['owner'])
    end
  end

  def manager?(permission, owner)
    return true if owner
    return true if permission ^ 32 < permission
    return true if permission ^ 8 < permission

    false
  end

  def confirm!
    update confirm_token: nil
    update_info oauth_response
  end

  private_class_method :process_authentication
end
