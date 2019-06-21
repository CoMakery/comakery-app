class AddNumberOfAssignmentsPerUserToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :number_of_assignments_per_user, :integer, default: 1
  end
end
