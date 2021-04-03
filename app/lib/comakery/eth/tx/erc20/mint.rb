class Comakery::Eth::Tx::Erc20::Mint < Comakery::Eth::Tx::Erc20::Transfer
  def method_id
    '40c10f19'
  end

  def method_name
    'mint'
  end
end
