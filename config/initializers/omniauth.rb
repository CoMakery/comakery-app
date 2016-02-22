Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer
  provider :slack, ENV["SLACK_API_KEY"], ENV["SLACK_API_SECRET"], scope: "client"
end

OmniAuth.configure do |config|
  config.on_failure = SessionsController.action(:oauth_failure)
end
