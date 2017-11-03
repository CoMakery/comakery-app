require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before do
    WebMock.reset!
    WebMock.reset_callbacks
  end
end
