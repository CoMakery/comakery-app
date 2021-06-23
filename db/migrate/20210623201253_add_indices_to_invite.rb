class AddIndicesToInvite < ActiveRecord::Migration[6.0]
  def change
    remove_index :invites, :email
    add_index :invites, [:invitable_id, :invitable_type], unique: true
    add_index :invites, [:invitable_id, :invitable_type, :email], unique: true
  end
end
