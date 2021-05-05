class Comakery::Eth::Tx::Erc20::BatchTransfer < Comakery::Eth::Tx::Erc20
  def to_object(**_args)
    super.merge({
      to: blockchain_transaction.token.batch_contract_address,
      contract: {
        abi: blockchain_transaction.token.batch_abi,
        method: method_name,
        parameters: encode_method_params
      }
    })
  end

  def method_name
    'batchTransfer'
  end

  def method_params
    [
      blockchain_transaction.contract_address,
      blockchain_transaction.destinations,
      blockchain_transaction.amounts
    ]
  end

  def abi
    JSON.parse(File.read(Rails.root.join('vendor/abi/coin_types/batch_transfer.json')))
  end

  def valid_to?
    to == blockchain_transaction.token.batch_contract_address.downcase
  end
end
