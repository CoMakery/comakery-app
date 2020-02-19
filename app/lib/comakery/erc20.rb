class Comakery::Erc20
  def initialize(contract_address, abi, network, nonce)
    @nonce = nonce
    @contract = Ethereum::Contract.create(
      name: 'ERC20 Contract',
      address: contract_address,
      abi: abi,
      client: Ethereum::HttpClient.new(
        "https://#{network == 'main' ? 'mainnet' : network}.infura.io/v3/#{ENV.fetch('INFURA_PROJECT_ID')}"
      )
    )
  end

  def functions
    @functions ||= Ethereum::Abi.parse_abi(@contract.abi)[1]
  end

  def method_missing(method_name, *args)
    tx(
      @contract.call_payload(
        functions.find { |f| f.name == method_name },
        args
      )
    )
  end

  private

    def tx(data)
      Eth::Tx.new(data: data,
                  gas_limit: 21_000_000,
                  gas_price: 3_141_592,
                  nonce: @nonce,
                  to: @contract.address,
                  value: 0)
    end
end
