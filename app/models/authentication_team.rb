class AuthenticationTeam < ApplicationRecord
  belongs_to :authentication
  belongs_to :account
  belongs_to :team
  has_many :projects, through: :account
  validates :account, :team, :authentication, presence: true

  def name
    authentication.oauth_response['info']['name'] if authentication.oauth_response
  end

  def channels
    return @channels if @channels

    if slack
      result = GetSlackChannels.call(authentication_team: self)
      @channels = result.channels
    else
      @channels = team.decorate.channel_for_selects
    end
    @channels
  end

  def slack
    @slack ||= Comakery::Slack.get(authentication.token) if authentication.provider == 'slack'
  end
end
