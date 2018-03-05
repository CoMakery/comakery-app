class RefactorAwards < ActiveRecord::Migration[5.1]
  def change
    remove_column :awards, :issuer_id, :integer
    rename_column :awards, :authentication_id, :account_id
  end
end
