class ChangeProjectColumnFromQuarterlyToMonthly < ActiveRecord::Migration[4.2]
  def change
    rename_column(:projects, :maximum_royalties_per_quarter, :maximum_royalties_per_month)
  end
end
