# This file is used by Rack-based servers to start the application.

require ::File.expand_path('config/environment', __dir__)
system('RAILS_ENV=test bundle exec rake docs:generate &') if Rails.env.development?
run Rails.application
