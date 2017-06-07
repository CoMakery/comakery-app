require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative 'initializers/i18n'

module Comakery
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.default_locale = :app
    config.i18n.fallbacks =[:en]

    config.allow_signup = true
    config.project_slug = Dir.pwd.split(File::SEPARATOR).last.underscore
    # appears in main layout meta tag

    # lib/ is for code that is entirely independent of your Rails app
    # app/lib/ is for code that expects Rails (esp. models) but which is not itself a model
    config.autoload_paths << Rails.root.join("app", "lib")
    config.autoload_paths << Rails.root.join("app", "interactors")

    # e-mail
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { :api_key => ENV['POSTMARK_API_KEY'] }

    routes.default_url_options[:host] = ENV['APP_HOST'] || "localhost:#{ENV['PORT'] || 3000}"
    routes.default_url_options[:protocol] = ENV['APP_PROTOCOL'] || 'https://'

    cloudfront_host = ENV['CLOUDFRONT_HOST']
    if cloudfront_host.present?
      config.action_controller.asset_host = cloudfront_host
      config.font_assets.origin = "http://#{ENV['APP_HOST']}"
    end

    config.allow_missing_ethereum_bridge = false

    config.airbrake = false

    config.ethereum_explorer_site = ENV['ETHEREUM_EXPLORER_SITE'] || raise("Please set ETHEREUM_EXPLORER_SITE environment variable")

    config.allow_ethereum = ENV['ALLOW_ETHEREUM']
  end
end
