class TokenType::Eos < TokenType
  # Generated template for implementing a new token type subclass
  # See: rails g token_type -h

  # Name of the token type for UI purposes
  # @return [String] name
  def name
    'EOS'
  end

  # Symbol of the token type for UI purposes
  # @return [String] symbol
  def symbol
    'EOS'
  end

  # Number of decimals
  # @return [Integer] number
  def decimals
    18
  end

  # Wallet logo filename for UI purposes (relative to `app/assets/images`)
  # @return [String] filename
  def wallet_logo
    'eos.png'
  end

  # Contract instance if implemented
  # @return [nil]
  def contract
    # Comakery::Eth::Contract::Erc20.new
  end

  # ABI structure if present
  # @return [Hash] abi
  def abi
    {}
  end

  # Transaction instance if implemented
  # @return [nil]
  def tx
    # Comakery::Eth::Tx.new
  end

  # Does it have support for smart contracts?
  # @return [Boolean] flag
  def operates_with_smart_contracts?
    false
  end

  # Does it have custom account data stored on chain?
  # @return [Boolean] flag
  def operates_with_account_records?
    false
  end

  # Does it have support for account groups?
  # @return [Boolean] flag
  def operates_with_reg_groups?
    false
  end

  # Does it have support for transfer restrictions between accounts/groups?
  # @return [Boolean] flag
  def operates_with_transfer_rules?
    false
  end

  # Does it have support for minting new tokens to a custom address?
  # @return [Boolean] flag
  def supports_token_mint?
    false
  end

  # Does it have support for burning existing tokens from a custom address?
  # @return [Boolean] flag
  def supports_token_burn?
    false
  end

  # Does it have support for temporal freezing of all token transactions?
  # @return [Boolean] flag
  def supports_token_freeze?
    false
  end
end
