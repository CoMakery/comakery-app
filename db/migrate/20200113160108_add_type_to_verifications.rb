class AddTypeToVerifications < ActiveRecord::Migration[6.0]
  def change
    add_column :verifications, :verification_type, :integer, default: 0, null: false
  end
end
