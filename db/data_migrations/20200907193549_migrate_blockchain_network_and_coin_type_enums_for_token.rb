# rubocop:disable Metrics/CyclomaticComplexity

class MigrateBlockchainNetworkAndCoinTypeEnumsForToken < ActiveRecord::DataMigration
  def up
    Token.where(_blockchain: nil).find_each do |t|
      blockchain = case t.blockchain_network
                   when 'bitcoin_mainnet'
                     :bitcoin
                   when 'bitcoin_testnet'
                     :bitcoin_test
                   when 'cardano_mainnet'
                     :cardano
                   when 'cardano_testnet'
                     :cardano_test
                   when 'qtum_mainnet'
                     :qtum
                   when 'qtum_testnet'
                     :qtum_test
                   when 'eos_mainnet'
                     :eos
                   when 'eos_testnet'
                     :eos_test
                   when 'tezos_mainnet'
                     :tezos
                   when 'constellation_mainnet'
                     :constellation
                   when 'constellation_testnet'
                     :constellation_test
                   when 'main'
                     :ethereum
                   when 'ropsten'
                     :ethereum_ropsten
                   when 'kovan'
                     :ethereum_kovan
                   when 'rinkeby'
                     :ethereum_rinkeby
      end

      t.update(_blockchain: blockchain)
    end

    Token.where(_token_type: nil).find_each do |t|
      type = case t.coin_type
             when 'erc20'
               :erc20
             when 'eth'
               :eth
             when 'qrc20'
               :qrc20
             when 'qtum'
               :qtum
             when 'ada'
               :ada
             when 'btc'
               :btc
             when 'eos'
               :eos
             when 'xtz'
               :xtz
             when 'comakery'
               :comakery
             when 'dag'
               :dag
      end

      t.update(_token_type: type)
    end
  end
end
