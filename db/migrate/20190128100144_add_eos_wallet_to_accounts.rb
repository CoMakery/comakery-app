class AddEosWalletToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :eos_wallet, :string
  end
end
