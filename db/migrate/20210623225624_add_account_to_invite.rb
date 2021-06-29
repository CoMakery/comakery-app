class AddAccountToInvite < ActiveRecord::Migration[6.0]
  def change
    add_reference :invites, :account, foreign_key: true
  end
end
