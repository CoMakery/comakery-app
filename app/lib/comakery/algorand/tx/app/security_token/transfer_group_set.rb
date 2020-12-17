class Comakery::Algorand::Tx::App::SecurityToken::TransferGroupSet < Comakery::Algorand::Tx::App
  def valid_app_accounts?(blockchain_transaction)
    transaction_app_accounts[0] == blockchain_transaction.blockchain_transactable.account.address_for_blockchain(blockchain_transaction.token._blockchain)
  end

  def valid_app_args?(blockchain_transaction)
    transaction_app_args[0] == 'transfer group' \
    && transaction_app_args[1] == 'set' \
    && transaction_app_args[2] == blockchain_transaction.blockchain_transactable.reg_group.blockchain_id.to_s
  end
end
