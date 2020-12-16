class Comakery::Algorand::Tx::App::OptIn < Comakery::Algorand::Tx::App
  def valid?(blockchain_transaction)
    super && transaction_on_completion == 'optin'
  end
end
