# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class PopulateEthereumAuthAddressForAccountsWhichWereUsingIt < ActiveRecord::DataMigration
  def up
    Account.where.not(nonce: nil).find_each do |a|
      if a.ethereum_wallet.present? && a.email.present? && !a.email.match?(/0x.+@comakery.com/)
        a.update_column(:ethereum_auth_address, a.ethereum_wallet)
      end
    end
  end
end
