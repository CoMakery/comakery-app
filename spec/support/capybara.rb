require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'

# References:
# https://about.gitlab.com/2017/12/19/moving-to-headless-chrome/
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/spec/support/capybara.rb

# Define an error class for JS console messages
JSConsoleError = Class.new(StandardError)

# Filter out innocuous JS console messages
JS_CONSOLE_FILTER = Regexp.union([
                                   '"[HMR] Waiting for update signal from WDS..."',
                                   '"[WDS] Hot Module Replacement enabled."',
                                   'https://fb.me/react-devtools',
                                   'Failed to load resource: net::ERR_FAILED',
                                   "No 'Access-Control-Allow-Origin' header is present on the requested resource."
                                 ])

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    # This enables access to logs with `page.driver.manage.get_log(:browser)`
    loggingPrefs: {
      browser: 'ALL',
      client: 'ALL',
      driver: 'ALL',
      server: 'ALL'
    }
  )

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('window-size=1240,1400')

  # Chrome won't work properly in a Docker container in sandbox mode
  options.add_argument('no-sandbox')

  # Run headless by default unless CHROME_HEADLESS specified
  options.add_argument('headless') unless ENV['CHROME_HEADLESS'] =~ /^(false|no|0)$/i

  # Disable /dev/shm use in CI. See https://gitlab.com/gitlab-org/gitlab-ee/issues/4252
  options.add_argument('disable-dev-shm-usage') if ENV['CI'] || ENV['CI_SERVER']

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities,
    options: options
  )
end

Capybara.javascript_driver = :chrome
Capybara.ignore_hidden_elements = true

# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run
# From https://github.com/mattheworiordan/capybara-screenshot/issues/84#issuecomment-41219326
Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end
Capybara::Screenshot.autosave_on_failure = false

RSpec.configure do |config|
  config.before(:example, :js) do
    session = Capybara.current_session

    # reset window size between tests
    unless session.current_window.size == [1240, 1400]
      begin
        session.current_window.resize_to(1240, 1400)
      rescue
        nil
      end
    end
  end

  config.after(:example, :js) do |example|
    # when a test fails, display any messages in the browser's console
    if example.exception
      console = page.driver.browser.manage.logs.get(:browser)&.reject { |log| log.message =~ JS_CONSOLE_FILTER }
      if console.present?
        message = "Unexpected browser console output:\n" + console.map(&:message).join("\n")
        raise JSConsoleError, message
      end
    end
  end

  config.append_after(:each) do
    # prevent localStorage from introducing side effects based on test order
    unless ['', 'about:blank', 'data:,'].include? Capybara.current_session.driver.browser.current_url
      execute_script('localStorage.clear();')
    end

    Capybara.reset_sessions!
  end
end
