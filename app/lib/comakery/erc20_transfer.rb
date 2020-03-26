class Comakery::Erc20Transfer < Comakery::EthTx
  def valid_method_id?
    input && input[0...8] == 'a9059cbb'
  end

  def method_arg_1
    valid_method_id? && input[8...(8 + 2 * 32)]&.to_i(16)&.to_s(16)&.insert(0, '0x')
  end

  def method_arg_2
    valid_method_id? && input[(8 + 2 * 32)...(8 + 2 * 32 + 2 * 32)]&.to_i(16)
  end

  def valid?(source, token_contract_address, destination, amount, time)
    return false unless super(source, token_contract_address, 0, time)
    return false if method_arg_1 != destination
    return false if method_arg_2 != amount
    true
  end
end
