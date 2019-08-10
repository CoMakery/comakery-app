class AddAgreedToLicenseHashToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :agreed_to_license_hash, :string
  end
end
