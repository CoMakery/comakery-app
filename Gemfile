source 'https://rubygems.org'
ruby '2.3.0'

gem 'airbrake', '< 5'
gem 'annotate'
gem 'coffee-rails'
gem 'compass-rails'
gem "d3-rails"
gem "font-awesome-rails"
gem 'fortitude', git: "https://github.com/ageweke/fortitude.git", ref: '3de1286652874506802a75befde0f11d79a0ec67'  # change when gem released
gem 'foundation-icons-sass-rails'
gem 'foundation-rails'
gem 'font_assets'
gem 'httparty'
gem 'interactor'
gem 'jquery-rails'
gem "nilify_blanks"
gem 'modernizr-rails'
gem 'momentjs-rails'
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
gem 'sinatra', :require => nil  # for sidekiq admin interface
gem 'sdoc',          group: :doc
gem 'sidekiq'
gem 'slack-ruby-client'
gem 'uglifier'
gem 'underscore-rails'

group(:development, :test) do
  gem 'awesome_print'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'fuubar'
  gem 'guard-rspec', require: false
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack_session_access'
  gem 'rerun'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'typhoeus'
end

group(:development) do
  gem 'brakeman', require: false
  gem 'easy_shell'
  gem 'git-storyid'
  # gem 'html2fortitude'  # requires old ruby_parser, try global "gem install html2fortitude" instead
  gem 'foreman'
  gem 'letter_opener'
  gem 'meta_request'
  gem 'pivotal_git_scripts'
  gem 'quiet_assets'
  gem 'spring-commands-rspec'
  gem 'spring'
  gem 'web-console'
  gem 'xray-rails'
end

group(:test) do
  gem 'webmock'
end
