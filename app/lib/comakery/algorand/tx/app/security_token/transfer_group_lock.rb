class Comakery::Algorand::Tx::App::SecurityToken::TransferGroupLock < Comakery::Algorand::Tx::App
  def valid_app_args?(blockchain_transaction)
    transaction_app_args[0] == 'transfer group' \
    && transaction_app_args[1] == 'lock' \
    && transaction_app_args[2] == blockchain_transaction.blockchain_transactable.sending_group.blockchain_id.to_s \
    && transaction_app_args[3] == blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id.to_s \
    && transaction_app_args[4] == blockchain_transaction.blockchain_transactable.lockup_until.to_i.to_s
  end
end
