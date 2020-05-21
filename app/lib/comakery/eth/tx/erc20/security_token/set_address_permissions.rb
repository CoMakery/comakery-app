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

  # Allow longer list of params for validation:
  # rubocop:disable Metrics/ParameterLists
  # rubocop:disable Metrics/CyclomaticComplexity
  def valid?(source, token_contract_address, time, address, group_id, time_lock_until, max_balance, status)
    return false unless super(source, token_contract_address, 0, time)
    return false if method_arg_0 != address.downcase
    return false if method_arg_1 != group_id
    return false if method_arg_2 != time_lock_until.to_i
    return false if method_arg_3 != max_balance
    return false if method_arg_4 != status
    true
  end
end
