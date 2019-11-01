class AddInterestedCountToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :interests_count, :bigint
  end
end
