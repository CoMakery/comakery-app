class Comakery::Erc20
  attr_reader :nonce, :client, :contract

  def initialize(contract_address, abi, network, nonce)
    @nonce = nonce
    @client = Ethereum::HttpClient.new(
      "https://#{network.to_s == 'main' ? 'mainnet' : network}.infura.io/v3/#{ENV.fetch('INFURA_PROJECT_ID', '')}"
    )
    @contract = Ethereum::Contract.create(
      name: 'Contract',
      address: contract_address,
      abi: abi,
      client: @client
    )
    @functions = Ethereum::Abi.parse_abi(@contract.abi)[1]
  end

  def method_missing(method_name, *args)
    function = @functions.find { |f| f.name.casecmp?(method_name.to_s) }

    if function
      tx(@contract.call_payload(function, args))
    else
      super
    end
  end

  def respond_to_missing?(method_name, *args)
    @functions.any? { |f| f.name.casecmp?(method_name.to_s) } || super
  end

  def tx_status(tx_hash, number_of_confirmations = 1)
    tx = @client.eth_get_transaction_receipt(tx_hash)
    current_block = @client.eth_block_number&.fetch('result', nil)&.to_i(16)
    block_number = tx&.fetch('result', nil)&.fetch('blockNumber', nil)&.to_i(16)
    status = tx&.fetch('result', nil)&.fetch('status', nil)&.to_i(16)

    return nil unless block_number && status
    return nil unless current_block - block_number >= number_of_confirmations

    status
  end

  private

    def tx(data)
      Eth::Tx.new(
        data: data,
        gas_limit: 100000,
        gas_price: 10000,
        nonce: @nonce,
        to: @contract.address,
        value: 0
      )
    end
end
