class Comakery::Algorand::Tx::App::OptIn < Comakery::Algorand::Tx::App
  def app_transaction_on_completion
    'optin'
  end

  def valid_addresses?
    blockchain_transaction.source == sender_address
  end
end
