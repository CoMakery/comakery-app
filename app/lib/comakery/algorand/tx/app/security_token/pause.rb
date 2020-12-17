class Comakery::Algorand::Tx::App::SecurityToken::Pause < Comakery::Algorand::Tx::App
  def app_args(_blockchain_transaction)
    %w[
      pause
      1
    ]
  end
end
