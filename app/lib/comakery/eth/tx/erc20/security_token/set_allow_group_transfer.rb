class Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer < Comakery::Eth::Tx::Erc20
  def method_name
    'setAllowGroupTransfer'
  end

  def method_params
    [
      blockchain_transaction.blockchain_transactable.sending_group.blockchain_id,
      blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id,
      blockchain_transaction.blockchain_transactable.lockup_until.to_i
    ]
  end
end
