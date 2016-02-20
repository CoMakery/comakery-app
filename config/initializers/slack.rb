Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Slack::RealTime.configure do |config|
  config.concurrency = Slack::RealTime::Concurrency::Celluloid
end
