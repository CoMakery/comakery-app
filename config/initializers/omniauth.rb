Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer
  provider :slack, ENV["SLACK_API_KEY"], ENV["SLACK_API_SECRET"], scope: [
    'commands',        # slash commands
    'chat:write:bot',  # write to any channel or PM user (in their Slackbot PM channel)
    'users:read',      # get user email address
    # 'team:read',
    # identify
  ] * ','

end

OmniAuth.configure do |config|
  config.on_failure = SessionsController.action(:oauth_failure)
end
