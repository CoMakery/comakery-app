class WriteNewAwardColumnValues < ActiveRecord::Migration
  def up
    Award.reset_column_information
    AwardType.write_all_award_amounts
  end

  def down
  end
end
