Recaptcha.configure do |config|
  config.skip_verify_env << Rails.env unless [ENV['RECAPTCHA_SITE_KEY'], ENV['RECAPTCHA_SECRET_KEY'], ENV['RECAPTCHA_SITE_KEY_V2'], ENV['RECAPTCHA_SECRET_KEY_V2']].all?

  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
end