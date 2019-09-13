class CreateJoinTableAccountProject < ActiveRecord::Migration[5.1]
  def change
    create_join_table :accounts, :projects do |t|
      t.index [:account_id, :project_id]
      t.index [:project_id, :account_id]
    end
  end
end
