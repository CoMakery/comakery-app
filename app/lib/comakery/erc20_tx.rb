class Comakery::Erc20Tx < Comakery::EthTx
  def transfer?
    input && input[0...8] == 'a9059cbb'
  end

  def transfer_to
    transfer? && input[8...(8 + 2 * 32)]&.to_i(16)&.to_s(16)&.insert(0, '0x')
  end

  def transfer_value
    transfer? && input[(8 + 2 * 32)...(8 + 2 * 32 + 2 * 32)]&.to_i(16)
  end

  def valid?(source, token_contract_address, destination, amount, time)
    return false unless super(source, token_contract_address, 0, time)
    return false if transfer_to != destination
    return false if transfer_value != amount
    true
  end
end
