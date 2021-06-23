class RemoveRoleFromInvite < ActiveRecord::Migration[6.0]
  def change
    remove_column :invites, :role, :string
  end
end
