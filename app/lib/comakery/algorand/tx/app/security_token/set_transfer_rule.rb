class Comakery::Algorand::Tx::App::SecurityToken::SetTransferRule < Comakery::Algorand::Tx::App
  def app_args
    [
      'setTransferRule',
      blockchain_transaction.blockchain_transactable.sending_group.blockchain_id,
      blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id,
      blockchain_transaction.blockchain_transactable.lockup_until.to_i
    ]
  end

  def valid_addresses?
    blockchain_transaction.source == sender_address
  end
end
