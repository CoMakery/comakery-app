class Comakery::Eth
  attr_reader :client

  def initialize(host)
    @client = Ethereum::HttpClient.new(
      "https://#{host}/v3/#{ENV.fetch('INFURA_PROJECT_ID', '')}"
    )
  end

  def current_block
    client&.eth_block_number&.fetch('result', nil)&.to_i(16)
  end
end
