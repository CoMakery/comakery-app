Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer
  provider :slack, ENV["SLACK_API_KEY"], ENV["SLACK_API_SECRET"], scope: [
    'commands',            # slash commands
    'chat:write:bot',      # write to any channel or PM user (in their Slackbot PM channel)
    'reactions:write',     # create "reaction" emoticons
    'users:read',          # required to log in for some teams
    'users:read.email',    # needed for new apps
    'team:read',           # required to log in for some teams
    'channels:read'
  ] * ','
end

OmniAuth.configure do |config|
  config.on_failure = SessionsController.action(:oauth_failure)
end
