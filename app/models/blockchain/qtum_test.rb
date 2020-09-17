class Blockchain::QtumTest < Blockchain::Qtum
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'QtumTest'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    'testnet.qtum.info'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'testnet.qtum.org'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
