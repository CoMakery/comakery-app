class TokenType::Qrc20 < TokenType
  # Template for implementing a new token type
  # See parent class at `app/models/token_type.rb` for details

  def initialize
    super

    # Name of the token type for UI purposes
    @name = 'QRC20'

    # Symbol of the token type for UI purposes
    @symbol = 'QRC20'

    # Number of decimals
    @decimals = 8

    # Contract class if implemented
    # @contract = Comakery::Eth::Contract::Erc20

    # Transaction class if implemented
    # @tx = Comakery::Eth::Tx
  end
end
