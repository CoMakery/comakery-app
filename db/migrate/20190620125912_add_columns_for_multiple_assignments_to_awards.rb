class AddColumnsForMultipleAssignmentsToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :number_of_assignments, :integer, default: 1
    add_column :awards, :cloned_on_assignment_from_id, :integer
  end
end
