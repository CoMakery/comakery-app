class AddNewAwardNoticeToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :new_award_notice, :boolean, default: false
  end
end
