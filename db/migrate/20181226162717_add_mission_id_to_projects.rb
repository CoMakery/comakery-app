class AddMissionIdToProjects < ActiveRecord::Migration[5.1]
  def change
    add_reference :projects, :mission, index: true
  end
end
