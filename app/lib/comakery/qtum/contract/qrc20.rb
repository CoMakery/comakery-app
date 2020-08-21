class Comakery::Qtum::Contract::Qrc20
  attr_reader :contract

  def initialize(contract_address, network)
    @contract = Comakery::Qtum.new(network).contract(contract_address)
  end

  def symbol
    contract.dig('qrc20', 'symbol')
  end

  def decimals
    contract.dig('qrc20', 'decimals')&.to_i
  end
end
