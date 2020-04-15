class Comakery::Erc20
  attr_reader :nonce, :contract, :functions

  def initialize(contract_address, abi, network, nonce)
    @nonce = nonce
    @contract = Ethereum::Contract.create(
      name: 'Contract',
      address: contract_address,
      abi: abi,
      client: Comakery::Eth.new(network).client
    )
    @functions = Ethereum::Abi.parse_abi(contract.abi)[1]
  end

  def method_missing(method_name, *args)
    function = functions.find { |f| f.name.casecmp?(method_name.to_s) }

    if function
      tx(contract.call_payload(function, args))
    else
      super
    end
  end

  def respond_to_missing?(method_name, *args)
    functions.any? { |f| f.name.casecmp?(method_name.to_s) } || super
  end

  private

    def tx(data)
      Eth::Tx.new(
        data: data,
        gas_limit: 100000,
        gas_price: 10000,
        nonce: nonce,
        to: contract.address,
        value: 0
      )
    end
end
