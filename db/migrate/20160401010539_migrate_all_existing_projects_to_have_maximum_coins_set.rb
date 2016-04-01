class MigrateAllExistingProjectsToHaveMaximumCoinsSet < ActiveRecord::Migration
  def change
    Project.update_all(maximum_coins: 10_000_000)
  end
end
