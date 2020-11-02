class Blockchain
  # See `app/models/blockchain/*`

  # List of available blockchains as an attribute for enum definition
  def self.list
    h = { bitcoin: 0, bitcoin_test: 1, cardano: 2, cardano_test: 3, qtum: 4, qtum_test: 5, eos: 6, eos_test: 7, tezos: 8, constellation: 9, constellation_test: 10, ethereum: 11, ethereum_ropsten: 12, ethereum_kovan: 13, ethereum_rinkeby: 14, algorand: 15, algorand_test: 16, algorand_beta: 17 } # Populated automatically by BlockchainGenerator

    h.values.uniq.size == h.values.size ? h : raise('Invalid list of blockchains')
  end

  def self.append_to_list(blockchain)
    list.merge(blockchain => (list.values.max + 1))
  end

  def self.all
    list.keys.map { |k| "Blockchain::#{k.to_s.camelize}".constantize.new }
  end

  def self.without_testnets
    all.filter!(&:mainnet?)
  end

  def self.available
    testnets_available? ? all : without_testnets
  end

  def self.testnets_available?
    ActiveModel::Type::Boolean.new.cast(ENV.fetch('TESTNETS_AVAILABLE', 'true'))
  end

  def testnets_available?
    self.class.testnets_available?
  end

  def self.find_with_ore_id_name(name)
    all.select(&:supported_by_ore_id?).find { |b| b.ore_id_name == name }
  end

  # 'Blockchain::BitcoinTest' => 'bitcoin_test'
  def key
    self.class.name.demodulize.underscore
  end
end
