class Comakery::Algorand::Tx::App::SecurityToken::Transfer < Comakery::Algorand::Tx::App
  def app_args(blockchain_transaction)
    [
      'transfer',
      blockchain_transaction.amount.to_s
    ]
  end

  def app_accounts(blockchain_transaction)
    [
      blockchain_transaction.destination
    ]
  end
end
