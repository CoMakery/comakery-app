class AddAgreedToLicenseHashToAward < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :agreed_to_license_hash, :string
  end
end
