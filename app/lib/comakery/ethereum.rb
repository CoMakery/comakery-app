class Comakery::Ethereum
  ADDRESS = {
    account: {
      length: 40
    },
    transaction: {
      length: 64
    }
  }.freeze

  include HTTParty
  # debug_output $stdout # good for debugging HTTP, but logs API key :(

  class << self
    TIMEOUT = 10.minutes

    def token_contract(params)
      call_ethereum_bridge('project', params, 'contractAddress')
    end

    def token_issue(params)
      call_ethereum_bridge('token_issue', params, 'tx')
    end

    def call_ethereum_bridge(path, params, response_key)
      ethereum_bridge = ENV['ETHEREUM_BRIDGE']
      if ethereum_bridge.blank?
        return if Comakery::Application.config.allow_missing_ethereum_bridge
      elsif ENV['ETHEREUM_BRIDGE_API_KEY'].blank?
        raise('please set env var ETHEREUM_BRIDGE_API_KEY')
      end

      url = URI.join ethereum_bridge, path
      headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      private_params = params.merge apiKey: ENV['ETHEREUM_BRIDGE_API_KEY']

      response = post url,
                      body: private_params.to_json,
                      headers: headers,
                      timeout: TIMEOUT

      begin
        response.parsed_response.fetch(response_key)
      rescue StandardError => e
        raise "Error received: #{response.parsed_response.inspect}
          From request to: #{url}
          With params: #{JSON.pretty_generate params}
          Original error:
          #{e.message}
          #{e.backtrace}
        "
      end
    end
  end
end
