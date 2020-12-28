class Comakery::Algorand::Tx::App::SecurityToken::Pause < Comakery::Algorand::Tx::App
  def app_args
    %w[
      pause
      1
    ]
  end
end
