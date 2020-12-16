class Comakery::Algorand::Tx::App::SecurityToken::Burn < Comakery::Algorand::Tx::App
  def valid_app_accounts?(_blockchain_transaction)
    transaction_app_accounts[0] == blockchain_transaction.destination
  end

  def valid_app_args?(blockchain_transaction)
    transaction_app_args[0] == 'burn'
    transaction_app_args[1] == blockchain_transaction.amount
  end
end
