class AddProofIdToAwards < ActiveRecord::Migration
  def up
    add_column :awards, :proof_id, :text

    Award.where(proof_id: nil).each do |award|
      award.update proof_id: SecureRandom.base58(22)
    end

    change_column :awards, :proof_id, :text, :null => false
  end

  def down
    remove_column :awards, :proof_id
  end
end
