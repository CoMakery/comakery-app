class Comakery::Algorand::Tx::App::SecurityToken::LockUntil < Comakery::Algorand::Tx::App
  def valid_app_accounts?(_blockchain_transaction)
    transaction_app_accounts[0] == blockchain_transaction.destination
  end

  def valid_app_args?(_blockchain_transaction)
    transaction_app_args[0] == 'lock until'
    transaction_app_args[1] == Time.current.to_i.to_s # TODO: update to actual value
  end
end
