class AddProofLinkToAwards < ActiveRecord::Migration[4.2]
  def change
    add_column :awards, :proof_link, :string
  end
end
