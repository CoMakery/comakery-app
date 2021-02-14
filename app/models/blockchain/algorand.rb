class Blockchain::Algorand < Blockchain
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'Algorand'
  end

  def main_api_host
    'api.algoexplorer.io'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    "#{main_api_host}/idx2"
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'algoexplorer.io'
  end

  def api_host
    "#{main_api_host}/v2"
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    true
  end

  # Number of confirmations to wait before marking transaction as successful
  # @return [Integer] number
  def number_of_confirmations
    1
  end

  # Seconds to wait between syncs with block explorer API
  # @return [Integer] seconds
  def sync_period
    60
  end

  # Maximum number of syncs with block explorer API
  # @return [Integer] number
  def sync_max
    10
  end

  # Seconds to wait when transaction is created
  # @return [Integer] seconds
  def sync_waiting
    600
  end

  # Transaction url on block explorer website
  # @return [String] url
  def url_for_tx_human(hash)
    "https://#{explorer_human_host}/tx/#{hash}"
  end

  # Transaction url on block explorer API
  # @return [String] url
  def url_for_tx_api(hash)
    "https://#{explorer_api_host}/v2/transactions?txid=#{hash}"
  end

  # Address url on block explorer website
  # @return [String] url
  def url_for_address_human(addr)
    "https://#{explorer_human_host}/address/#{addr}"
  end

  # Address url on block explorer API
  # @return [String] url
  def url_for_address_api(addr)
    "https://#{explorer_api_host}/v2/accounts/#{addr}"
  end

  # Asset url on block explorer API
  # @return [String] url
  def url_for_asset_api(asset_id)
    "https://#{explorer_api_host}/v2/assets/#{asset_id}"
  end

  # App url on block explorer API
  # @return [String] url
  def url_for_app_api(app_id)
    "https://#{explorer_api_host}/v2/applications/#{app_id}"
  end

  def url_for_status_api
    "https://#{api_host}/status"
  end

  # Validate blockchain transaction hash
  # @raise [Blockchain::Tx::ValidationError]
  # @return [void]
  def validate_tx_hash(hash)
    raise Blockchain::Tx::ValidationError, 'should consist of 52 alphanumeric characters' unless /\A[0-9A-Za-z]{52}\z/.match?(hash)
  end

  # Validate blockchain address
  # @raise [Blockchain::Address::ValidationError]
  # @return [void]
  def validate_addr(addr)
    raise Blockchain::Address::ValidationError, 'should consist of 58 alphanumeric characters' unless /\A[0-9A-Za-z]{58}\z/.match?(addr)
  end

  # Validate Algorand asset id
  # @raise [Blockchain::Address::ValidationError]
  # @return [void]
  def validate_asset(asset_id)
    return if asset_id.to_i.positive?

    raise Blockchain::Address::ValidationError, 'should be integer value'
  end

  # Validate Algorand app id
  # @raise [Blockchain::Address::ValidationError]
  # @return [void]
  def validate_app(app_id)
    return if app_id.to_i.positive?

    raise Blockchain::Address::ValidationError, 'should be integer value'
  end

  # Is it supported by OreId service
  # @return [Boolean] flag
  def supported_by_ore_id?
    true
  end

  # Name of the blockchain on OreId service, if supported
  # @return [String] name
  def ore_id_name
    'algo_main'
  end

  # Return coin balance of provided addr
  # @return [Integer] balance
  def account_coin_balance(addr)
    Comakery::Algorand.new(self).account_balance(addr)
  end

  # Return current block
  # @return [Integer] current block
  def current_block
    Comakery::Algorand.new(self).last_round
  end
end
