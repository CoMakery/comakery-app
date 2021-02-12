class TokenType::AlgorandSecurityToken < TokenType
  # Generated template for implementing a new token type subclass
  # See: rails g token_type -h

  # Name of the token type for UI purposes
  # @return [String] name
  def name
    'ALGORAND_SECURITY_TOKEN'
  end

  # Symbol of the token type for UI purposes
  # @return [String] symbol
  def symbol
    contract.app_global_state_decoded['symbol']
  end

  # Number of decimals
  # @return [Integer] number
  def decimals
    contract.app_global_state_decoded['decimals']
  end

  # Wallet logo filename for UI purposes (relative to `app/assets/images`)
  # @return [String] filename
  def wallet_logo
    'OREID_Logo_Symbol.svg'
  end

  # Contract instance if implemented
  # @return [nil]
  def contract
    @contract ||=
      begin
        blockchain.validate_app(contract_address)
        contract = Comakery::Algorand.new(blockchain, nil, contract_address)
        @contract = contract
      end
  rescue Blockchain::Address::ValidationError, NoMethodError
    raise TokenType::Contract::ValidationError, 'is invalid'
  end

  # ABI structure if present
  # @return [Hash] abi
  def abi
    {}
  end

  # Transaction instance if implemented
  # @return [nil]
  def tx
    # Comakery::Eth::Tx.new.new
  end

  # Does it have support for smart contracts?
  # @return [Boolean] flag
  def operates_with_smart_contracts?
    true
  end

  # Does it have custom account data stored on chain?
  # @return [Boolean] flag
  def operates_with_account_records?
    true
  end

  # Does it have support for account groups?
  # @return [Boolean] flag
  def operates_with_reg_groups?
    true
  end

  # Does it have support for transfer restrictions between accounts/groups?
  # @return [Boolean] flag
  def operates_with_transfer_rules?
    true
  end

  # Does it have support for minting new tokens to a custom address?
  # @return [Boolean] flag
  def supports_token_mint?
    true
  end

  # Does it have support for burning existing tokens from a custom address?
  # @return [Boolean] flag
  def supports_token_burn?
    true
  end

  # Does it have support for temporal freezing of all token transactions?
  # @return [Boolean] flag
  def supports_token_freeze?
    true
  end

  def contract_address
    attrs[:contract_address]
  end

  def blockchain
    attrs[:blockchain]
  end
end
