class Comakery::Algorand::Tx::App::SecurityToken::Mint < Comakery::Algorand::Tx::App
  def app_args
    [
      'mint',
      blockchain_transaction.amount.to_s
    ]
  end

  def app_accounts
    [
      blockchain_transaction.destination
    ]
  end
end
