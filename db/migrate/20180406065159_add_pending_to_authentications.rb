class AddPendingToAuthentications < ActiveRecord::Migration[5.1]
  def change
    add_column :authentications, :confirm_token, :string
  end
end
