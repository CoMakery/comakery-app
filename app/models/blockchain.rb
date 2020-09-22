class Blockchain
  # See `app/models/blockchain/*`

  # List of available blockchains as an attribute for enum definition
  def self.list
    h = { bitcoin: 0, bitcoin_test: 1, cardano: 2, cardano_test: 3, qtum: 4, qtum_test: 5, eos: 6, eos_test: 7, tezos: 8, constellation: 9, constellation_test: 10, ethereum: 11, ethereum_ropsten: 12, ethereum_kovan: 13, ethereum_rinkeby: 14 } # Populated automatically by BlockchainGenerator

    h.values.uniq.size == h.values.size ? h : raise('Invalid list of blockchains')
  end

  def self.append_to_list(blockchain)
    list.merge(blockchain => (list.values.max + 1))
  end
end
