class Blockchain::Constellation < Blockchain
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'Constellation'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    ENV['BLOCK_EXPLORER_URL_CONSTELLATION_MAINNET']
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    explorer_api_host
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    true
  end

  # Number of confirmations to wait before marking transaction as successful
  # @return [Integer] number
  def number_of_confirmations
    0
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
    "https://#{explorer_human_host}/transactions/#{hash}"
  end

  # Transaction url on block explorer API
  # @return [String] url
  def url_for_tx_api(hash)
    "https://#{explorer_api_host}/transactions/#{hash}"
  end

  # Address url on block explorer website
  # @return [String] url
  def url_for_address_human(addr)
    url_for_address_api(addr)
  end

  # Address url on block explorer API
  # @return [String] url
  def url_for_address_api(addr)
    "https://#{explorer_human_host}/transactions?address=#{addr}"
  end

  # Validate blockchain transaction hash
  # @raise [Blockchain::Tx::ValidationError]
  # @return [void]
  def validate_tx_hash(hash)
    raise Blockchain::Tx::ValidationError if hash.blank?
  end

  # Validate blockchain address
  # @raise [Blockchain::Address::ValidationError]
  # @return [void]
  def validate_addr(addr)
    raise Blockchain::Address::ValidationError if addr.blank?
  end
end
