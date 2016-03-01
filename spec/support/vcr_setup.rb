VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/vcr'
  # your HTTP request service. You can also use fakeweb, webmock, and more
  c.hook_into :faraday
end

RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].downcase.gsub(/\W+/, "_").split("_", 2).join("/")
    VCR.use_cassette(name, :record => :new_episodes) do
      example.call
    end
  end
end
