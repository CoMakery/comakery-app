class RemoveSlackFieldsFromAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :name
    remove_column :accounts, :uid
    remove_column :accounts, :provider
  end
end
