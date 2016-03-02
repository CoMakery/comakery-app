source 'https://rubygems.org'
ruby '2.3.0'

gem 'airbrake', '< 5'
gem 'coffee-rails'
gem 'compass-rails', '< 3'
gem 'ethereum'
gem 'faye-websocket'  # used by slack-ruby-client for concurrency
gem 'fortitude', git: "https://github.com/ageweke/fortitude.git", ref: '3de1286652874506802a75befde0f11d79a0ec67'  # change when gem released
gem 'foundation-icons-sass-rails'
gem 'foundation-rails', '< 6'
gem 'jbuilder'
gem 'jquery-rails'
gem "nilify_blanks"
gem 'nokogiri'
gem 'omniauth-slack'
gem 'omniauth'
gem 'pg'
gem 'postmark-rails'
gem 'premailer-rails'
gem 'puma'
gem 'pundit'
gem 'rails_12factor', group: :production
gem 'rails', '4.2.5.2'
gem "refile", require: "refile/rails"
gem "refile-mini_magick"
gem "refile-s3"
gem 'responders'
gem 'sass-rails'
gem 'sdoc',          group: :doc
gem 'slack-ruby-client'
gem 'sucker_punch'
gem 'uglifier'

group(:test) do
  gem 'webmock'
  gem 'vcr'
end

group(:development, :test) do
  gem 'awesome_print'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'faker'
  gem 'fuubar'
  gem 'guard-rspec', require: false
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack_session_access'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'typhoeus'
end

group(:development) do
  gem 'git-storyid'
  gem 'html2fortitude'
  gem 'letter_opener'
  gem 'meta_request'
  gem 'pivotal_git_scripts'
  gem 'quiet_assets'
  gem 'spring-commands-rspec'
  gem 'spring'
  gem 'web-console'
  gem 'xray-rails'
end
