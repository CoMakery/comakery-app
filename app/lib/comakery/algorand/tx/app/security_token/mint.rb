class Comakery::Algorand::Tx::App::SecurityToken::Mint < Comakery::Algorand::Tx::App
  def app_args
    [
      'mint',
      blockchain_transaction.amount
    ]
  end

  def app_accounts
    [
      blockchain_transaction.destination
    ]
  end

  def valid_amount?
    valid_app_args?
  end

  def valid_addresses?
    blockchain_transaction.source == sender_address
  end
end
