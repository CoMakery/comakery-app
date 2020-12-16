class Comakery::Algorand::Tx::App::SecurityToken::TransferGroupSet < Comakery::Algorand::Tx::App
  def valid_app_accounts?(_blockchain_transaction)
    transaction_app_accounts[0] == blockchain_transaction.destination
  end

  def valid_app_args?(_blockchain_transaction)
    transaction_app_args[0] == 'transfer group'
    transaction_app_args[1] == 'set'
    transaction_app_args[2] == 'group id' # TODO: update to actual value
  end
end
