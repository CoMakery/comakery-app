require 'rest-client'
class Comakery::Discord
  def initialize(token = nil)
    @token = token ? "Bearer #{token}" : "Bot #{ENV['DISCORD_BOT_TOKEN']}"
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
    "https://discordapp.com/api/oauth2/authorize?client_id=#{ENV['DISCORD_CLIENT_ID']}&scope=bot&permissions=536870913"
  end

  def webhook(channel_id)
    webhook = webhooks(channel_id).select { |h| h['name'] == 'Comakery' }.first
    return webhook if webhook
    @path = "/channels/#{channel_id}/webhooks"
    @data = { name: 'Comakery' }.to_json
    post_result
  end

  def webhooks(channel_id)
    @path = "/channels/#{channel_id}/webhooks"
    result
  end

  def send_message(award)
    channel_id = award.channel.channel_id
    wh = webhook channel_id
    @path = "/webhooks/#{wh['id']}/#{wh['token']}"
    message = AwardMessage.call(award: award).notifications_message
    @data = { content: message }.to_json
    post_result(false)
  end

  private

  def result
    url = "https://discordapp.com/api#{@path}"
    res = RestClient.get(url, Authorization: @token)
    JSON.parse(res)
  rescue RestClient::Forbidden => e
    { error: e.message }
  end

  def post_result(parse_json = true)
    url = "https://discordapp.com/api#{@path}"
    header = { Authorization: @token, content_type: :json, accept: :json }
    res = RestClient.post(url, @data, header)
    parse_json ? JSON.parse(res) : res
  end
end
