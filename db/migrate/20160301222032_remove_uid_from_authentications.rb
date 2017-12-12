class RemoveUidFromAuthentications < ActiveRecord::Migration[4.2]
  def change
    remove_column :authentications, :uid, :string, null: false, default: ""
  end
end
