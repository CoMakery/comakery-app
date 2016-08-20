class AddProofLinkToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :proof_link, :string
  end
end
