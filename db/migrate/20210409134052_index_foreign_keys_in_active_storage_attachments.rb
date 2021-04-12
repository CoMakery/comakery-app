class IndexForeignKeysInActiveStorageAttachments < ActiveRecord::Migration[6.0]
  def change
    add_index :active_storage_attachments, :record_id
  end
end
