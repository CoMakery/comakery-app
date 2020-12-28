if Comakery::Discord.enabled?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'email identify guilds'
  end
end
