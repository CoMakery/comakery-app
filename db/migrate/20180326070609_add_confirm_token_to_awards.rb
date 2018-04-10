class AddConfirmTokenToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :confirm_token, :string
  end
end
