class RenameAutoAddInterestColumnForProjects < ActiveRecord::Migration[6.0]
  def change
    rename_column :projects, :auto_add_interest, :auto_add_account
  end
end
