class FillWalletForAccountTokenRecord < ActiveRecord::DataMigration
  def up
    AccountTokenRecord.where(wallet: nil).includes(:token, :reg_group).find_each do |atr|
      wallet = Wallet.find_by(account_id: atr.account_id, _blockchain: atr.token._blockchain)
      atr.update(wallet: wallet) if wallet
    end
  end

  def down
    AccountTokenRecord.update_all(wallet: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end
