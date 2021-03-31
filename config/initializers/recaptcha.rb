Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  config.skip_verify_env << Rails.env if ENV['RECAPTCHA_SITE_KEY'].blank? && ENV['RECAPTCHA_SECRET_KEY'].blank?
end
