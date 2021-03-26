class Blockchain::EthereumRopsten < Blockchain::Ethereum
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'EthereumRopsten'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    'ropsten.infura.io'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'ropsten.etherscan.io'
  end

  # Name of the blockchain on OreId service, if supported
  # @return [String] name
  def ore_id_name
    'eth_ropsten'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
