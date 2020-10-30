class SetStatusDefaultForSyncrhonisation < ActiveRecord::Migration[6.0]
  def change
    change_column_default :synchronisations, :status, 0
    change_column_null :synchronisations, :status, false
  end
end
