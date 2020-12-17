class Comakery::Algorand::Tx::App::OptIn < Comakery::Algorand::Tx::App
  def valid_transaction_on_completion?
    transaction_on_completion == 'optin'
  end
end
