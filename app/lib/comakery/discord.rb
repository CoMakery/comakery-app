require 'rest-client'
class Comakery::Discord
  def initialize(token)
    @token = "Bearer #{token}"
  end

  def guilds
    url = 'https://discordapp.com/api/users/@me/guilds'
    res = RestClient.get(url, Authorization: @token)
    JSON.parse(res)
  end
end
