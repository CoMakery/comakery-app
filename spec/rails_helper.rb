# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start :rails do
  SimpleCov.minimum_coverage 98
  SimpleCov.minimum_coverage_by_file 50
  SimpleCov.refuse_coverage_drop

  # add_filter == do not track coverage
  # add_filter %r{^/lib/generators/}

  add_group 'Decorators', 'app/decorators'
  add_group 'Interactors', 'app/interactors'
  add_group 'Policies', 'app/policies'
end

require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'rack_session_access/capybara'
require 'sidekiq/testing'
require 'pundit/rspec'
require 'active_storage_validations/matchers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include ModelValidations, type: :model

  if ENV['THOROUGH'].present?
    config.render_views # shows problems, but very slow
  end

  config.include FeatureHelper, type: :feature
  config.include SlackStubs, type: :feature
  config.include ConstellationStubs, type: :feature

  config.include ActiveSupport::Testing::TimeHelpers

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join('spec', 'fixtures') # rubocop:todo Rails/FilePath

  config.before do
    Sidekiq::Worker.clear_all
  end

  config.before(:suite) do
    Webpacker.compile
  end

  if Bullet.enable?
    config.before(:each) { Bullet.start_request }
    config.after(:each)  { Bullet.end_request }
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.filter_gems_from_backtrace \
    'actionpack',
    'actionview',
    'activesupport',
    'rack',
    'railties',
    'zeus'

  config.after(:each, type: :feature) do
    logout
  end
end

def login_account(account)
  session[:account_id] = account.id
end

def login(account)
  account.authentications.first || create(:authentication, account_id: account.id)

  if request
    request.session[:account_id] = account.id
  else
    session[:account_id] = account.id
  end

  account
end

def logout
  session[:account_id] = nil
end

def get_award_type_rows # rubocop:todo Naming/AccessorMethodName
  page.all('.award-type-row')
end

def get_channel_rows # rubocop:todo Naming/AccessorMethodName
  page.all('.channel-row')
end

def click_remove(award_type_row)
  award_type_row.find('a[data-mark-and-hide]').click
end

def wait_for_turbolinks
  has_css?('.turbo-progress-bar', visible: true)
  has_no_css?('.turbo-progress-bar')
end

include SlackStubs # rubocop:todo Style/MixinUsage
include ConstellationStubs # rubocop:todo Style/MixinUsage

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
