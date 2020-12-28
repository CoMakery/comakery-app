class Comakery::Algorand::Tx::Asset < Comakery::Algorand::Tx
  attr_reader :asset_id

  def initialize(blockchain_transaction)
    @blockchain_transaction = blockchain_transaction
    @algorand = Comakery::Algorand.new(blockchain_transaction.token.blockchain, nil)
    @hash = blockchain_transaction.tx_hash
    @asset_id = blockchain_transaction.token.contract_address
  end

  def to_object
    {
      type: 'axfer',
      from: blockchain_transaction.source,
      to: blockchain_transaction.destination,
      amount: blockchain_transaction.amount,
      assetId: asset_id
    }
  end

  def transaction_asset_id
    transaction_data.dig('asset-transfer-transaction', 'asset-id') || 0
  end

  def receiver_address
    transaction_data.dig('asset-transfer-transaction', 'receiver') || ''
  end

  # In the minimal Asset token unit
  # amount 100 mean 1.00 when Asset decimal is 2
  def amount
    transaction_data.dig('asset-transfer-transaction', 'amount') || 0
  end

  def valid?(_)
    super && asset_id.to_i == transaction_asset_id
  end
end
