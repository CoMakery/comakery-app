class AddNotifyOnExpirationAtToAward < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :notify_on_expiration_at, :datetime
  end
end
