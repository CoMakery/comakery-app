class AddExpiresAtToAward < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :expires_at, :datetime
  end
end
