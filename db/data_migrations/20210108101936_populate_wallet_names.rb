class PopulateWalletNames < ActiveRecord::DataMigration
  def up
    Wallet.find_each do |wallet|
      wallet.name = wallet.blockchain.name
      wallet.save
    end
  end

  def down; end
end
