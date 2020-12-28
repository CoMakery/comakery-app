class Comakery::Algorand::Tx::App::SecurityToken::Unpause < Comakery::Algorand::Tx::App
  def app_args
    %w[
      pause
      0
    ]
  end
end
