class Blockchain::AlgorandTest < Blockchain::Algorand
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'AlgorandTest'
  end

  def main_api_host
    'api.testnet.algoexplorer.io'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'testnet.algoexplorer.io'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end

  # Name of the blockchain on OreId service, if supported
  # @return [String] name
  def ore_id_name
    'algo_test'
  end
end
