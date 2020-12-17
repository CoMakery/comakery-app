class Comakery::Algorand::Tx::App::SecurityToken::MaxBalance < Comakery::Algorand::Tx::App
  def app_args(blockchain_transaction)
    [
      'max balance',
      blockchain_transaction.blockchain_transactable.max_balance.to_s
    ]
  end

  def app_accounts(blockchain_transaction)
    [
      blockchain_transaction.blockchain_transactable.account.address_for_blockchain(blockchain_transaction.token._blockchain)
    ]
  end
end
