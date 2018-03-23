require 'rest-client'
class Comakery::Discord
  def initialize(token = nil)
    @token = token ? "Bearer #{token}" : 'Bot NDI2MjM1MTc2NDg2Njk5MDA4.DZXpfw.4qFMkXNNO8_NC-xlcsfYQCaMJmE'
  end

  def guilds
    @path = '/users/@me/guilds'
    result
  end

  def channels(team)
    @path = "/guilds/#{team.team_id}/channels"
    result
  end

  def members(team)
    @path = "/guilds/#{team.team_id}/members"
    result
  end

  def add_bot_link
    "https://discordapp.com/api/oauth2/authorize?client_id=#{ENV['DISCORD_CLIENT_ID']}&scope=bot&permissions=1"
  end

  private

  def result
    url = "https://discordapp.com/api/v7#{@path}"
    res = RestClient.get(url, Authorization: @token)
    JSON.parse(res)
  rescue
    []
  end
end
