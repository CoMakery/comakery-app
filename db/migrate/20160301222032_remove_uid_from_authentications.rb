class RemoveUidFromAuthentications < ActiveRecord::Migration
  def change
    remove_column :authentications, :uid, :string, null: false, default: ""
  end
end
