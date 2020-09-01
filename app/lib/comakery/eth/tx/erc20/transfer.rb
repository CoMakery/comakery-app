class Comakery::Eth::Tx::Erc20::Transfer < Comakery::Eth::Tx::Erc20
  def method_id
    'a9059cbb'
  end

  def method_arg_0
    lookup_method_arg(0)&.to_s(16)&.insert(0, '0x') # rubocop:todo Rails/SkipsModelValidations
  end

  def method_arg_1
    lookup_method_arg(1)
  end

  def valid?(blockchain_transaction)
    return false unless super
    return false if method_arg_0 != blockchain_transaction.destination.downcase
    return false if method_arg_1 != blockchain_transaction.amount

    true
  end
end
