class Comakery::Algorand::Tx::App::SecurityToken::Pause < Comakery::Algorand::Tx::App
  def app_args
    [
      'pause',
      1
    ]
  end

  def valid_addresses?
    blockchain_transaction.source == sender_address
  end
end
