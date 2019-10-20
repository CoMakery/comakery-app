class AddFrozenToToken < ActiveRecord::Migration[5.1]
  def change
    add_column :tokens, :token_frozen, :boolean, default: false
  end
end
