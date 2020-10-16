class AddOreIdToWallets < ActiveRecord::Migration[6.0]
  def change
    add_reference :wallets, :ore_id, foreign_key: true
  end
end
