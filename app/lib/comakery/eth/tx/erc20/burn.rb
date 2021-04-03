class Comakery::Eth::Tx::Erc20::Burn < Comakery::Eth::Tx::Erc20::Transfer
  def method_id
    '9dc29fac'
  end

  def method_name
    'burn'
  end
end
