class Comakery::Eth::Tx::Erc20::Transfer < Comakery::Eth::Tx::Erc20
  def method_name
    'transfer'
  end

  def method_params
    [
      blockchain_transaction.destination,
      blockchain_transaction.amount
    ]
  end
end
