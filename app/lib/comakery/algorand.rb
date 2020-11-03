class Comakery::Algorand
  attr_reader :client

  def initialize(host)
    @api_endpoint = "https://#{host}"
  end

  def fetch_symbol_and_decimals(asset_id)
    asset_params = asset_details(asset_id).dig('asset', 'params')
    return [nil, nil] unless asset_params

    [
      asset_params.fetch('unit-name'),
      asset_params.fetch('decimals')
    ]
  end

  def asset_details(asset_id)
    get_request('/v2/assets/', asset_id)
  end

  def get_request(path, params = {})
    url = "#{@api_endpoint}#{path}#{params.to_param}"
    HTTParty.get(url)
  end
end
