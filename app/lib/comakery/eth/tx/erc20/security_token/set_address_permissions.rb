class Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions < Comakery::Eth::Tx::Erc20
  def method_id
    '45d11299'
  end

  def method_arg_0
    lookup_method_arg(0) && lookup_method_arg(0).to_s(16).insert(0, '0x')
  end

  def method_arg_1
    lookup_method_arg(1)
  end

  def method_arg_2
    lookup_method_arg(2)
  end

  def method_arg_3
    lookup_method_arg(3)
  end

  def method_arg_4
    lookup_method_arg(4) == 1
  end

  # Allow longer list of values for validation:
  # rubocop:disable Metrics/CyclomaticComplexity
  def valid?(blockchain_transaction)
    return false unless super
    return false if method_arg_0 != blockchain_transaction.blockchain_transactable.account.ethereum_wallet.downcase
    return false if method_arg_1 != blockchain_transaction.blockchain_transactable.reg_group.blockchain_id
    return false if method_arg_2 != blockchain_transaction.blockchain_transactable.lockup_until.to_i
    return false if method_arg_3 != blockchain_transaction.blockchain_transactable.max_balance
    return false if method_arg_4 != blockchain_transaction.blockchain_transactable.account_frozen
    true
  end
end
