class Comakery::Algorand::Tx::App::SecurityToken::TransferGroupLock < Comakery::Algorand::Tx::App
  def app_args(blockchain_transaction)
    [
      'transfer group',
      'lock',
      blockchain_transaction.blockchain_transactable.sending_group.blockchain_id.to_s,
      blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id.to_s,
      blockchain_transaction.blockchain_transactable.lockup_until.to_i.to_s
    ]
  end
end
