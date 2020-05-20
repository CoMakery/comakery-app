class Comakery::Eth::Tx::Erc20::Transfer < Comakery::Eth::Tx::Erc20
  def method_id
    'a9059cbb'
  end

  def method_arg_0
    lookup_method_arg(0) && lookup_method_arg(0).to_s(16).insert(0, '0x')
  end

  def method_arg_1
    lookup_method_arg(1)
  end

  def valid?(source, token_contract_address, destination, amount, time)
    return false unless super(source, token_contract_address, 0, time)
    return false if method_arg_0 != destination.downcase
    return false if method_arg_1 != amount
    true
  end
end
