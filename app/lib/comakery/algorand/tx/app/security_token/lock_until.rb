class Comakery::Algorand::Tx::App::SecurityToken::LockUntil < Comakery::Algorand::Tx::App
  def app_args(blockchain_transaction)
    [
      'lock until',
      blockchain_transaction.blockchain_transactable.lockup_until.to_i.to_s
    ]
  end

  def app_accounts(blockchain_transaction)
    [
      blockchain_transaction.blockchain_transactable.account.address_for_blockchain(blockchain_transaction.token._blockchain)
    ]
  end
end
