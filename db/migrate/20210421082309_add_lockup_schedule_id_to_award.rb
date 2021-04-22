class AddLockupScheduleIdToAward < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :lockup_schedule_id, :integer
  end
end
