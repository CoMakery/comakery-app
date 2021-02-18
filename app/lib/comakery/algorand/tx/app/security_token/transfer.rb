class Comakery::Algorand::Tx::App::SecurityToken::Transfer < Comakery::Algorand::Tx::App
  def app_args
    [
      'transfer',
      blockchain_transaction.amount
    ]
  end

  def app_accounts
    [
      blockchain_transaction.destination
    ]
  end

  def valid_amount?
    valid_app_args?
  end
end
