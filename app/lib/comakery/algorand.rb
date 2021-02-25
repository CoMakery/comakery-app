class Comakery::Algorand
  def initialize(blockchain, asset_id = nil, app_id = nil)
    @blockchain = blockchain
    @asset_id = asset_id.to_i
    @app_id = app_id.to_i
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

  def app_details
    @app_details ||= get_request(@blockchain.url_for_app_api(@app_id))
  end

  def app_global_state
    app_details.dig('application', 'params', 'global-state')
  end

  def app_global_state_decoded
    decode_storage(app_global_state)
  end

  def decode_storage(storage)
    storage.map do |e|
      [
        Base64.decode64(e['key']),
        decode_storage_value(e['value'])
      ]
    end.to_h
  end

  def decode_storage_value(value)
    case value['type']
    when 1
      Base64.decode64(value['bytes'])
    when 2
      value['uint']
    end
  end

  def transaction_details(tx_hash)
    return {} if tx_hash.blank?

    get_request(@blockchain.url_for_tx_api(tx_hash))
  end

  def account_details(addr)
    get_request(@blockchain.url_for_address_api(addr))
  end

  def account_balance(addr)
    account_details(addr).dig('account', 'amount')
  end

  def account_assets(addr)
    account_details(addr).dig('account', 'assets') || []
  end

  def account_apps(addr)
    account_details(addr).dig('account', 'apps-local-state') || []
  end

  def account_local_state(addr)
    account_apps(addr).find { |app| app['id'] == @app_id }
  end

  def account_local_state_decoded(addr)
    decode_storage(account_local_state(addr)['key-value'])
  end

  def status
    @status ||= get_request(@blockchain.url_for_status_api)
  end

  def last_round
    status.fetch('last-round', 0)
  end

  def get_request(url)
    HTTParty.get(url)
  end
end
