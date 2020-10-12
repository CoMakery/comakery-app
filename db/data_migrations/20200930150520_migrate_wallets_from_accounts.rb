# rubocop:disable Metrics/CyclomaticComplexity

class MigrateWalletsFromAccounts < ActiveRecord::DataMigration
  def up
    Account.find_each do |a|
      a.wallets.create(_blockchain: :ethereum, address: a.ethereum_wallet) if a.ethereum_wallet
      a.wallets.create(_blockchain: :qtum, address: a.qtum_wallet) if a.qtum_wallet
      a.wallets.create(_blockchain: :cardano, address: a.cardano_wallet) if a.cardano_wallet
      a.wallets.create(_blockchain: :bitcoin, address: a.bitcoin_wallet) if a.bitcoin_wallet
      a.wallets.create(_blockchain: :eos, address: a.eos_wallet) if a.eos_wallet
      a.wallets.create(_blockchain: :tezos, address: a.tezos_wallet) if a.tezos_wallet
      a.wallets.create(_blockchain: :constellation, address: a.constellation_wallet) if a.constellation_wallet
    end
  end
end
