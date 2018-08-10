class AddEmailToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :email, :string
  end
end
