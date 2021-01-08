class WriteNewAwardColumnValues < ActiveRecord::Migration[4.2]
  def up
    Award.reset_column_information
  end

  def down
  end
end