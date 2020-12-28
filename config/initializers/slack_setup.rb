if Comakery::Slack.enabled?
  Slack::RealTime.configure do |config|
    # config.concurrency = Slack::RealTime::Concurrency::Eventmachine

    # if reinstating this ^^^ add to gemfile:
    # gem 'faye-websocket'  # used by slack-ruby-client for concurrency
  end
end