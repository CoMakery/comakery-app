class CreateBatchTransactable < ActiveRecord::Migration[6.0]
  def change
    create_table :batch_transactables do |t|
      t.belongs_to :transaction_batch, foreign_key: true, index: { name: :idx_bt_on_tb }
      t.references :blockchain_transactable, polymorphic: true, index: { name: :idx_bt_on_btt_and_bti }
    end
  end
end
