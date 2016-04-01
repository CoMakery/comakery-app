class RemoveSlackFieldsFromAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :name, :string
    remove_column :accounts, :uid, :integer
    remove_column :accounts, :provider, :string
  end
end
