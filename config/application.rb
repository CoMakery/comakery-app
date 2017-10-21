require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative 'initializers/env'

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

    config.allow_signup = true
    config.company_github_url = env!('COMPANY_GITHUB_URL')
    config.company_email = env!('COMPANY_EMAIL')
    config.company_media = env!('COMPANY_MEDIA')
    config.company_name = env!('COMPANY_NAME')
    config.company_public_slack_url = env!('COMPANY_PUBLIC_SLACK_URL')
    config.company_twitter_url = env!('COMPANY_TWITTER_URL')
    config.logo_image = env!('LOGO_IMAGE')
    config.project_name = env!('PROJECT_NAME')
    config.project_slug = env!('PROJECT_SLUG', Dir.pwd.split(File::SEPARATOR).last.underscore) #, config.project_name.parameterize.underscore)
    config.tech_support_email = env!('TECH_SUPPORT_EMAIL')
    # appears in main layout meta tag
    config.project_description = 'Collaborate on products and share the revenue. Easily pay people for work with equity and royalties before you have money. Easy royalties for app makers.'
    # config.contact_email = "hello@ecsa.io"

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

    config.ethereum_explorer_site = env!('ETHEREUM_EXPLORER_SITE')

    config.allow_ethereum = ENV['ALLOW_ETHEREUM']
  end
end
