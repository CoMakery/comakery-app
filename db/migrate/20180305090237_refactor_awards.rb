class RefactorAwards < ActiveRecord::Migration[5.1]
  def change
    # rename_column :awards, :authentication_id, :account_id
    add_column :awards, :account_id, :integer
  end
end
