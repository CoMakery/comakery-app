require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/vcr'
  # your HTTP request service. You can also use fakeweb, webmock, and more
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].downcase.gsub(/\W+/, "_").split("_", 2).join("/")

    vcr_mode = (ENV["VCR_MODE"] || :none).to_sym
    raise "VCR_MODE set to '#{vcr_mode}' which is not one of {all, none, new_episodes}" unless vcr_mode.in?([:all, :none, :new_episodes])

    VCR.use_cassette(name, :record => vcr_mode) do
      example.call
    end
  end

  config.before(:each) do
    WebMock.reset!
    WebMock.reset_callbacks
  end
end
