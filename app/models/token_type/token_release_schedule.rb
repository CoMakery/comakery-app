class TokenType::TokenReleaseSchedule < TokenType::Erc20
  # Generated template for implementing a new token type subclass
  # See: rails g token_type -h

  # Name of the token type for UI purposes
  # @return [String] name
  def name
    'Token Release Schedule'
  end

  # Symbol of the token type for UI purposes
  # @return [String] symbol
  def symbol
    super
  end

  # Number of decimals
  # @return [Integer] number
  def decimals
    super
  end

  # Wallet logo filename for UI purposes (relative to `app/assets/images`)
  # @return [String] filename
  def wallet_logo
    super
  end

  # Contract instance if implemented
  # @return [nil]
  def contract
    super
  end

  # ABI structure if present
  # @return [Hash] abi
  def abi
    @abi ||= JSON.parse(File.read(Rails.root.join('vendor/abi/coin_types/lockup.json')))
  end

  # Transaction instance if implemented
  # @return [nil]
  def tx
    super
  end

  # Does it have support for smart contracts?
  # @return [Boolean] flag
  def operates_with_smart_contracts?
    super
  end

  # Does it have custom account data stored on chain?
  # @return [Boolean] flag
  def operates_with_account_records?
    super
  end

  # Does it have support for account groups?
  # @return [Boolean] flag
  def operates_with_reg_groups?
    super
  end

  # Does it have support for transfer restrictions between accounts/groups?
  # @return [Boolean] flag
  def operates_with_transfer_rules?
    super
  end

  # Does it have support for minting new tokens to a custom address?
  # @return [Boolean] flag
  def supports_token_mint?
    super
  end

  # Does it have support for burning existing tokens from a custom address?
  # @return [Boolean] flag
  def supports_token_burn?
    super
  end

  # Does it have support for temporal freezing of all token transactions?
  # @return [Boolean] flag
  def supports_token_freeze?
    super
  end

  # Does it have support for fetching balance?
  # @return [Boolean] flag
  def supports_balance?
    super
  end

  # Return balance of symbol for provided addr
  # @return [Integer] balance
  def blockchain_balance(_wallet_address)
    super
  end

  def blockchain_locked_balance(wallet_address)
    contract.contract.call.locked_balance_of(wallet_address)
  end

  def blockchain_unlocked_balance(wallet_address)
    contract.contract.call.unlocked_balance_of(wallet_address)
  end
end
