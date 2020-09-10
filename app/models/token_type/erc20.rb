class TokenType::Erc20 < TokenType
  # Generated template for implementing a new token type subclass
  # See: rails g token_type -h

  # Name of the token type for UI purposes
  # @return [String] name
  def name
    'ERC20'
  end

  # Symbol of the token type for UI purposes
  # @return [String] symbol
  def symbol
    @symbol ||= contract.symbol.to_s
  end

  # Number of decimals
  # @return [Integer] number
  def decimals
    @decimals ||= contract.decimals.to_i
  end

  # Contract instance if implemented
  # @return [nil]
  def contract
    @contract ||= Comakery::Eth::Contract::Erc20.new(contract_address, abi, blockchain.explorer_api_host, nil)
  end

  # Transaction instance if implemented
  # @return [nil]
  def tx
    # Comakery::Eth::Tx.new::Erc20
  end

  def contract_address
    attrs[:contract_address]
  end

  def abi
    attrs[:abi]
  end

  def blockchain
    attrs[:blockchain]
  end
end
