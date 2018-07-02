source 'https://rubygems.org'
ruby '2.3.1'

gem 'airbrake'
gem 'awesome_print'
gem 'bcrypt'
gem 'coffee-rails'
gem 'compass-rails'
gem 'countries', require: 'countries/global'
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
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'modernizr-rails'
gem 'momentjs-rails'
gem 'nilify_blanks'
gem 'omniauth'
gem 'omniauth-discord', git: 'https://github.com/ducle/omniauth-discord.git'
gem 'omniauth-slack'
gem 'pg'
gem 'premailer-rails'
gem 'puma'
gem 'pundit'
gem 'rails', '~>5.1.4'
gem 'rails_12factor', group: :production
gem 'redcarpet'
gem 'refile', require: 'refile/rails', git: 'https://github.com/refile/refile.git' # remove git path when version > refile gem > 0.6.2 is released (0.6.2 requires old conflicting rack)
gem 'refile-mini_magick'
gem 'refile-s3'
gem 'responders'
gem 'rubyzip'
gem 'sass-rails'
gem 'sdoc', group: :doc
gem 'sendgrid-ruby'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', require: nil # for sidekiq admin interface
gem 'slack-ruby-client'
gem 'uglifier'
gem 'underscore-rails'
gem 'webpacker'

group(:scripts) do
  gem 'easy_shell'
  gem 'trollop'
end

group(:development, :test) do
  gem 'brakeman', require: false
  gem 'citizen-scripts', git: 'https://github.com/CoMakery/citizen-scripts.git', ref: 'dev', require: false
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop', '~>0.49.1', require: false
  gem 'rubocop-rspec', '~>1.15.0'
end

group(:development) do
  gem 'better_errors'
  gem 'git-storyid'
  # gem 'html2fortitude'  # requires old ruby_parser, try global "gem install html2fortitude" instead
  gem 'letter_opener'
  gem 'meta_request'
  gem 'pivotal_git_scripts'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
end

group(:test) do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock'
end
