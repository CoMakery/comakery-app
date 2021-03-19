class Blockchain::EthereumKovan < Blockchain::Ethereum
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'EthereumKovan'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    'kovan.infura.io'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'kovan.etherscan.io'
  end

  # Name of the blockchain on OreId service, if supported
  # @return [String] name
  def ore_id_name
    'eth_kovan'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
