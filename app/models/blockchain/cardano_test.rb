class Blockchain::CardanoTest < Blockchain::Cardano
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'CardanoTest'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'cardano-explorer.cardano-testnet.iohkdev.io'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
