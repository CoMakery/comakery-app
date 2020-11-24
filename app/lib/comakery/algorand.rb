class Comakery::Algorand
  def initialize(blockchain, asset_id)
    @blockchain = blockchain
    @asset_id = asset_id
  end

  def symbol
    asset_details.dig('asset', 'params', 'unit-name')
  end

  def decimals
    asset_details.dig('asset', 'params', 'decimals')
  end

  def asset_details
    @asset_details ||= get_request(@blockchain.url_for_asset_api(@asset_id))
  end

  def transaction_details(tx_hash)
    @transaction_details ||= get_request(@blockchain.url_for_tx_api(tx_hash))
  end

  def get_request(url)
    HTTParty.get(url)
  end
end
