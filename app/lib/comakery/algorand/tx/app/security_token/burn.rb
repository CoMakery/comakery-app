class Comakery::Algorand::Tx::App::SecurityToken::Burn < Comakery::Algorand::Tx::App
  def app_args
    [
      'burn',
      blockchain_transaction.amount.to_s
    ]
  end

  def app_accounts
    [
      blockchain_transaction.destination
    ]
  end
end
