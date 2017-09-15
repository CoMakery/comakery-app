source 'https://rubygems.org'
ruby '2.3.1'

gem 'airbrake'
gem 'awesome_print'
gem 'coffee-rails'
gem 'compass-rails'
gem 'd3-rails', '~>3.5'
gem 'draper'
gem 'font-awesome-rails'
gem 'font_assets'
gem 'fortitude'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails', '~>6.2.4.0'
gem 'httparty'
gem 'interactor'
gem 'jquery-rails'
gem 'kaminari'
gem 'modernizr-rails'
gem 'momentjs-rails'
gem 'nilify_blanks'
gem 'omniauth'
gem 'omniauth-slack'
gem 'pg'
gem 'postmark-rails'
gem 'premailer-rails'
gem 'puma'
gem 'pundit'
gem 'rails', '4.2.7.1'
gem 'rails_12factor', group: :production
gem 'redcarpet'
gem 'refile', require: 'refile/rails'
gem 'refile-mini_magick'
gem 'refile-s3'
gem 'responders'
gem 'sass-rails'
gem 'sdoc', group: :doc
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', require: nil # for sidekiq admin interface
gem 'slack-ruby-client'
gem 'uglifier'
gem 'underscore-rails'

group(:scripts) do
  gem 'easy_shell'
  gem 'trollop'
end

group(:development, :test) do
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rerun'
end

group(:development) do
  gem 'brakeman', require: false
  gem 'git-storyid'
  # gem 'html2fortitude'  # requires old ruby_parser, try global "gem install html2fortitude" instead
  gem 'foreman'
  gem 'letter_opener'
  gem 'meta_request'
  gem 'pivotal_git_scripts'
  gem 'quiet_assets'
  gem 'rails_best_practices'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
end

group(:test) do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'guard-rspec', require: false
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rack_session_access'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'webmock'
end
