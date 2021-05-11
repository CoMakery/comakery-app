class RemoveRoleFromInterest < ActiveRecord::Migration[6.0]
  def change
    remove_column :interests, :role, :integer
  end
end
