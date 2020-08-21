class Blockchain::EosTest < Blockchain::Eos
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'EosTest'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'jungle.bloks.io'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    false
  end
end
