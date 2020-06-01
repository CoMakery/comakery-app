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

  def valid?(blockchain_transaction)
    return false unless super
    return false if method_arg_0 != blockchain_transaction.blockchain_transactable.sending_group.blockchain_id
    return false if method_arg_1 != blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id
    return false if method_arg_2 != blockchain_transactable.locked_until.to_i
    true
  end
end
