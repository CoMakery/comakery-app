class AddCommencementDateToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :commencement_date, :datetime
  end
end
