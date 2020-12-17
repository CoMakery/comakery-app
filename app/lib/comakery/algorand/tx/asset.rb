class Comakery::Algorand::Tx::Asset < Comakery::Algorand::Tx
  attr_reader :asset_id

  def initialize(blockchain, hash, asset_id)
    @algorand = Comakery::Algorand.new(blockchain, asset_id)
    @hash = hash
    @asset_id = asset_id
  end

  def to_object(blockchain_transaction)
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

  def valid?(blockchain_transaction)
    super && asset_id.to_i == transaction_asset_id
  end
end
