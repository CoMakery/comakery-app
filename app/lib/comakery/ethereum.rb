class Comakery::Ethereum

  class << self

    TIMEOUT = 10.minutes

    def token_contract args
      call_ethereum_bridge('project', args,'contractAddress')
    end

    def token_issue args
      call_ethereum_bridge('token_issue', args,'transactionId')
    end

    def call_ethereum_bridge(path, url_args, response_key)
      ethereum_bridge = ENV['ETHEREUM_BRIDGE'].presence
      return if ethereum_bridge.nil? && Comakery::Application.config.allow_missing_ethereum_bridge
      raise("please set env var ETHEREUM_BRIDGE") unless ethereum_bridge

      url = URI.join ethereum_bridge, path
      headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}

      url_args.merge! apiKey: ENV['ETHEREUM_BRIDGE_API_KEY']

      response = HTTParty.post url,
        body: url_args.to_json,
        headers: headers,
        timeout: TIMEOUT

      begin
        response.parsed_response.fetch(response_key)
      rescue => error
        message = "Error received: #{response.parsed_response.inspect}
          From request to: #{url}
          with params: #{JSON.pretty_generate url_args}
        "
        Airbrake.notify(Exception.new(message))
        nil
      end
    end
  end
end
