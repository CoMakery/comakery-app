class Comakery::Ethereum

  class << self

    TIMEOUT = 10.minutes

    def token_contract args
      ethereum_bridge = ENV['ETHEREUM_BRIDGE'].presence
      return if ethereum_bridge.nil? && Comakery::Application.config.allow_missing_ethereum_bridge
      raise("please set env var ETHEREUM_BRIDGE") unless ethereum_bridge

      url = URI.join ethereum_bridge, "project"
      headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}

      response = HTTParty.post url, body: args.to_json, headers: headers, timeout: TIMEOUT

      begin
        return response.parsed_response.fetch('contractAddress')
      rescue => error
        message = "Error received: #{response.parsed_response.inspect}
          From request to: #{url}
          with params: #{JSON.pretty_generate body}
        "
        Airbrake.notify(Exception.new(message))
        nil
      end
    end

    def token_issue args
      ethereum_bridge = ENV['ETHEREUM_BRIDGE'].presence
      return if ethereum_bridge.nil? && Comakery::Application.config.allow_missing_ethereum_bridge
      raise("please set env var ETHEREUM_BRIDGE") unless ethereum_bridge

      url = URI.join ethereum_bridge, "token_issue"
      headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      response = HTTParty.post url, body: args.to_json, headers: headers, timeout: TIMEOUT

      begin
        return response.parsed_response.fetch('transactionId')
      rescue => error
        message = "Error received: #{response.parsed_response.inspect}
          From request to: #{url}
          with params: #{JSON.pretty_generate body}
        "
        Airbrake.notify(Exception.new(message))
        nil
      end
    end
  end
end
