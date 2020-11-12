class CreateSynchronisations < ActiveRecord::Migration[6.0]
  def change
    create_table :synchronisations do |t|
      t.references :synchronisable, polymorphic: true, index: { name: 'idx_syncs_on_sync_type_and_sync_id' }
      t.integer :status

      t.timestamps
    end
  end
end
