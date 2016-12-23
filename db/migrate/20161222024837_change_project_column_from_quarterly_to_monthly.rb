class ChangeProjectColumnFromQuarterlyToMonthly < ActiveRecord::Migration
  def change
    rename_column(:projects, :maximum_royalties_per_quarter, :maximum_royalties_per_month)
  end
end
