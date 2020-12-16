class Blockchain::ConstellationTest < Blockchain::Constellation
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'ConstellationTest'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    ENV['BLOCK_EXPLORER_URL_CONSTELLATION_TESTNET'] || 'pdvmh8pagf.execute-api.us-west-1.amazonaws.com/cl-block-explorer-exchanges'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
