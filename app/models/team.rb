class Team < ApplicationRecord
  has_many :authentication_teams, dependent: :destroy
  has_many :accounts, through: :authentication_teams
  has_many :authentications, through: :authentication_teams
  has_many :projects, -> { distinct }, through: :authentication_teams

  def build_authentication_team(authentication)
    authentication_teams.find_or_create_by authentication: authentication, account: authentication.account
  end

  def authentication_team_by_account(account)
    authentication_teams.find_by account_id: account.id
  end

  def channels
    return [] unless discord?
    d_client = Comakery::Discord.new
    @channels ||= d_client.channels(self)
  end

  def parent_channels
    return @parent_channels if @parent_channels
    parents = channels.select { |c| c['parent_id'].nil? }
    @parent_channels = {}
    parents.each do |c|
      @parent_channels[c['id']] = c['name']
    end
    @parent_channels
  end

  def child_channels
    channels.reject { |c| c['parent_id'].nil? }
  end

  def channel_names
    return @channel_names if @channel_names
    @channel_names = []
    child_channels.each do |channel|
      parent_name = parent_channels[channel['parent_id']]
      @channel_names << "#{parent_name} - #{channel['name']}"
    end
    @channel_names
  end

  def discord?
    provider == 'discord'
  end
end
