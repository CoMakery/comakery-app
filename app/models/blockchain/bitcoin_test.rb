class Blockchain::BitcoinTest < Blockchain::Bitcoin
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'BitcoinTest'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'live.blockcypher.com/btc-testnet'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
