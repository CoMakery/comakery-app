class ChangeLockupScheduleId < ActiveRecord::Migration[6.0]
  def change
    change_column :awards, :lockup_schedule_id, :decimal, precision: 78, scale: 0
  end
end
