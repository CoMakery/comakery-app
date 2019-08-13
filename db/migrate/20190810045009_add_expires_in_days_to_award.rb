class AddExpiresInDaysToAward < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :expires_in_days, :integer, default: 10
  end
end
