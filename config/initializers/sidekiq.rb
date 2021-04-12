Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.custom_redis_params
end

Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.custom_redis_params
end