class Comakery::Eth::Tx::Erc20::SecurityToken::Unpause < Comakery::Eth::Tx::Erc20
  def method_name
    'unpause'
  end

  def method_params
    []
  end

  def valid?(blockchain_transaction)
    return false unless super

    true
  end
end
