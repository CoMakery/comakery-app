class Comakery::Algorand::Tx::App::SecurityToken::Unfreeze < Comakery::Algorand::Tx::App
  def valid_app_accounts?(blockchain_transaction)
    transaction_app_accounts[0] == blockchain_transaction.destination
  end

  def valid_app_args?(_blockchain_transaction)
    transaction_app_args[0] == 'freeze' \
    && transaction_app_args[1] == '0'
  end
end
