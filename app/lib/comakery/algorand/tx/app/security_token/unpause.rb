class Comakery::Algorand::Tx::App::SecurityToken::Unpause < Comakery::Algorand::Tx::App
  def valid_app_args?(_blockchain_transaction)
    transaction_app_args[0] == 'pause' \
    && transaction_app_args[1] == '0'
  end
end
