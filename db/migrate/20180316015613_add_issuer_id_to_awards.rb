class AddIssuerIdToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :issuer_id, :integer
  end
end
