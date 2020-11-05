class Comakery::Algorand
  def initialize(blockchain, asset_id)
    @blockchain = blockchain
    @api_endpoint = "https://#{@blockchain.explorer_api_host}"
    @asset_id = asset_id
  end

  def symbol
    asset_details.dig('asset', 'params', 'unit-name')
  end

  def decimals
    asset_details.dig('asset', 'params', 'decimals')
  end

  def asset_details
    @asset_details ||= get_request(@blockchain.asset_api_path(@asset_id))
  end

  def get_request(path, params = {})
    url = "#{@api_endpoint}#{path}#{params.to_param}"
    HTTParty.get(url)
  end
end
