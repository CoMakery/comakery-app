class AddTezosWalletToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :tezos_wallet, :string
  end
end
