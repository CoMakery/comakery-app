class AddInviteIdToAccount < ActiveRecord::Migration[6.0]
  def change
    add_reference :accounts, :invite, foreign_key: true
  end
end
