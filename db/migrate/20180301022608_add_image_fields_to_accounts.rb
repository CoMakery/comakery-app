class AddImageFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounts, :image
    add_column :accounts, :image_id, :string
    add_column :accounts, :image_filename, :string
    add_column :accounts, :image_content_zise, :string
    add_column :accounts, :image_content_type, :string
  end
end
