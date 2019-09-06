class AddUnlistedToToken < ActiveRecord::Migration[5.1]
  def change
    add_column :tokens, :unlisted, :bool, default: false
  end
end
