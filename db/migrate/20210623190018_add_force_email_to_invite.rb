class AddForceEmailToInvite < ActiveRecord::Migration[6.0]
  def change
    add_column :invites, :force_email, :bool, default: false, null: false
  end
end
