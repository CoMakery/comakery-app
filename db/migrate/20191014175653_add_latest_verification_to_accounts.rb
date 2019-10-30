class AddLatestVerificationToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :latest_verification_id, :bigint
  end
end
