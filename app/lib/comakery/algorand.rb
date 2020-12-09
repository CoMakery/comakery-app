class Comakery::Algorand
  def initialize(blockchain, asset_id = nil)
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
    return {} if tx_hash.blank?

    @transaction_details ||= get_request(@blockchain.url_for_tx_api(tx_hash))
  end

  def account_details(addr)
    @account_details ||= get_request(@blockchain.url_for_address_api(addr))
  end

  def account_balance(addr)
    account_details(addr).dig('account', 'amount')
  end

  def account_assets(addr)
    account_details(addr).dig('account', 'assets') || []
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
