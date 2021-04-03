class Comakery::Eth::Tx::Erc20::SecurityToken::Pause < Comakery::Eth::Tx::Erc20
  def method_id
    '8456cb59'
  end

  def method_name
    'pause'
  end

  def method_params
    []
  end

  def valid?(blockchain_transaction)
    return false unless super

    true
  end
end
