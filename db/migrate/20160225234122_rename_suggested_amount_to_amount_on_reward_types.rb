class RenameSuggestedAmountToAmountOnRewardTypes < ActiveRecord::Migration
  def change
    rename_column :reward_types, :suggested_amount, :amount
    add_column :rewards, :reward_type_id, :integer, null: false
    remove_column :rewards, :amount, :integer
    remove_column :rewards, :project_id, :integer, null: false
  end
end
