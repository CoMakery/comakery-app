class Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer < Comakery::Eth::Tx::Erc20
  def method_id
    'e98a0c64'
  end

  def method_arg_0
    lookup_method_arg(0)
  end

  def method_arg_1
    lookup_method_arg(1)
  end

  def method_arg_2
    lookup_method_arg(2)
  end

  def valid?(source, token_contract_address, time, from, to, locked_until)
    return false unless super(source, token_contract_address, 0, time)
    return false if method_arg_0 != from
    return false if method_arg_1 != to
    return false if method_arg_2 != locked_until.to_i
    true
  end
end
