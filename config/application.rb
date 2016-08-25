require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Comakery
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # one HTTP auth password for the entire site
    config.require_site_login = false # disabled by default
    config.site_username = 'foo'
    config.site_password = 'bar'

    config.allow_signup = true
    config.company_name = "CoMakery"
    config.project_name = "CoMakery"
    config.project_slug = "comakery"
    # appears in main layout meta tag
    config.project_description = "Coin distribution for dynamic equity organizations"
    config.contact_email = "hello@comakery.com"

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

    config.active_record.raise_in_transactional_callbacks = true

    config.airbrake = false

    config.ethercamp_subdomain = ENV['ETHERCAMP_SUBDOMAIN'] || raise("Please set ETHERCAMP_SUBDOMAIN environment variable")

    config.allow_ethereum = ENV['ALLOW_ETHEREUM']
  end
end
