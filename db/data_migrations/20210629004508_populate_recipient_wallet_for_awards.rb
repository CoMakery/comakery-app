class PopulateRecipientWalletForAwards < ActiveRecord::DataMigration
  def up
    Award.paid.where(recipient_wallet: nil).find_each do |award|
      award.populate_recipient_wallet
      award.save
    end
  end
end
