class PopulateWalletNames < ActiveRecord::DataMigration
  def up
    Wallet.select('array_agg(id) as ids, _blockchain').group(:_blockchain).each do |blockchain_wallets|
      blockchain = "Blockchain::#{blockchain_wallets._blockchain.camelize}".constantize.new

      Wallet.where(id: blockchain_wallets.ids).update_all(name: blockchain.name) # rubocop:todo Rails/SkipsModelValidations
    end
  end

  def down; end
end
