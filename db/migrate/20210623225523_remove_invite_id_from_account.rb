class RemoveInviteIdFromAccount < ActiveRecord::Migration[6.0]
  def change
    remove_reference :accounts, :invite, foreign_key: true
  end
end
