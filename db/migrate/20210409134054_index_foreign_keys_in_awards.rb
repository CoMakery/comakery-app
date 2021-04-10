class IndexForeignKeysInAwards < ActiveRecord::Migration[6.0]
  def change
    add_index :awards, :channel_id
    add_index :awards, :cloned_on_assignment_from_id
    add_index :awards, :image_id
    add_index :awards, :proof_id
    add_index :awards, :recipient_wallet_id
    add_index :awards, :submission_image_id
  end
end
