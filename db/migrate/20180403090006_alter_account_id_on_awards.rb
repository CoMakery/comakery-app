class AlterAccountIdOnAwards < ActiveRecord::Migration[5.1]
  def change
    change_column_null :awards, :account_id, true
  end
end
