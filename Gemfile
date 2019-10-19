source 'https://rubygems.org'
ruby '2.6.5'

gem 'airbrake', '~> 9.4'
gem 'awesome_print'
gem 'bcrypt'
gem 'bullet'
gem 'coffee-rails'
gem 'countries', require: 'countries/global'
gem 'd3-rails', '~>3.5'
gem 'draper'
gem 'font-awesome-rails'
gem 'font_assets'
gem 'fortitude'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails'
gem 'httparty'
gem 'interactor'
gem 'intercom-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'loofah', '>= 2.2.3'
gem 'modernizr-rails'
gem 'momentjs-rails'
gem 'nilify_blanks'
gem 'nokogiri'
gem 'olive_branch'
gem 'omniauth'
gem 'omniauth-discord', git: 'https://github.com/ducle/omniauth-discord.git'
gem 'omniauth-slack'
gem 'pg'
gem 'premailer-rails'
gem 'puma'
gem 'pundit'
gem 'rack', '>= 2.0.6'
gem 'rails', '~> 6.0'
gem 'rails-data-migrations'
gem 'rails-html-sanitizer'
gem 'react-rails'
gem 'redcarpet'
gem 'refile', require: 'refile/rails', git: 'https://github.com/refile/refile.git' # remove git path when version > refile gem > 0.6.2 is released (0.6.2 requires old conflicting rack)
gem 'refile-mini_magick', github: 'refile/refile-mini_magick'
gem 'refile-s3', github: 'refile/refile-s3'
gem 'responders'
gem 'rubyzip'
gem 'sass-rails'
gem 'schmooze'
gem 'sdoc', group: :doc
gem 'sendgrid-ruby'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', require: nil # for sidekiq admin interface
gem 'slack-ruby-client'
gem 'sprockets', '3.7.2'
gem 'uglifier'
gem 'underscore-rails'
gem 'web3-eth'
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
  gem 'capybara-screenshot', '~> 1.0'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 4.0.0.beta3'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

group(:production) do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

gem 'scout_apm', '~> 2.4'

gem 'mini_racer', '~> 0.2.4'

gem 'possessive', '~> 1.0'

gem 'omniauth-rails_csrf_protection', '~> 0.1.2'

gem 'redis-rails', '~> 5.0'

gem 'turbolinks', '~> 5.2'

gem 'ransack', '~> 2.3'

gem 'barnes', '~> 0.0.7'

gem 'bootsnap', '~> 1.4'
