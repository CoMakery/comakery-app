Slack::RealTime.configure do |config|
  config.concurrency = Slack::RealTime::Concurrency::Celluloid
end
