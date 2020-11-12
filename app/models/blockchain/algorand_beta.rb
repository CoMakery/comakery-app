class Blockchain::AlgorandBeta < Blockchain::Algorand
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'AlgorandBeta'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    'api.betanet.algoexplorer.io/idx2'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'betanet.algoexplorer.io'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end

  # Name of the blockchain on OreId service, if supported
  # @return [String] name
  def ore_id_name
    'algo_beta'
  end
end
