require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    match_requests_on: %i[method uri body]
  }

  %w[
    ORE_ID_API_KEY
    ORE_ID_SERVICE_KEY
  ].each do |sensitive_env_variable|
    c.filter_sensitive_data("ENV[#{sensitive_env_variable}]") { ENV[sensitive_env_variable] }
  end
end
