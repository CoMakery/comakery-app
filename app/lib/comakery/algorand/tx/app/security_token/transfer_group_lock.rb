class Comakery::Algorand::Tx::App::SecurityToken::TransferGroupLock < Comakery::Algorand::Tx::App
  def valid_app_args?(blockchain_transaction)
    transaction_app_args[0] == 'transfer group'
    transaction_app_args[1] == 'lock'
    transaction_app_args[2] == 'from group id' # TODO: Update to use actual value
    transaction_app_args[3] == 'to group id' # TODO: Update to use actual value
    transaction_app_args[4] == Time.current.to_i.to_s # TODO: Update to use actual value
  end
nd