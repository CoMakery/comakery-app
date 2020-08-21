class TokenType::Qrc20 < TokenType
  # Generated template for implementing a new token type subclass
  # See: rails g token_type -h

  # Name of the token type for UI purposes
  # @return [String] name
  def name
    'QRC20'
  end

  # Symbol of the token type for UI purposes
  # @return [String] symbol
  def symbol
    nil
  end

  # Number of decimals
  # @return [Integer] number
  def decimals
    nil
  end

  # Contract class if implemented
  # @return [nil]
  def contract
    Comakery::Qtum::Contract::Qrc20
  end

  # Transaction class if implemented
  # @return [nil]
  def tx
    # Comakery::Eth::Tx
  end
end
