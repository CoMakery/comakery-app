require 'capybara/rspec'
require 'capybara/poltergeist'

# Driver for remote debugging
Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false})
end

# Poltergeist every-day debugging: save_screenshot('screen.png', :selector => '#id')

Capybara.javascript_driver = :poltergeist
# Capybara.javascript_driver = :selenium
# Capybara.javascript_driver = :poltergeist_debug
# Use page.driver.debug to enable remote debugger; may have to open manually in Safari.
# Use binding.pry to pause execution and run ruby commands.
