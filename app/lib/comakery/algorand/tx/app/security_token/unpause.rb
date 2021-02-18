class Comakery::Algorand::Tx::App::SecurityToken::Unpause < Comakery::Algorand::Tx::App
  def app_args
    [
      'pause',
      0
    ]
  end

  def valid_addresses?
    blockchain_transaction.source == sender_address
  end
end
