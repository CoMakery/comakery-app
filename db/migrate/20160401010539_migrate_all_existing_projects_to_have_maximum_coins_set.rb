class MigrateAllExistingProjectsToHaveMaximumCoinsSet < ActiveRecord::Migration[4.2]
  def up
    Project.where(maximum_coins: 0).update_all(maximum_coins: 10_000_000)
  end

  def down
    puts "no-op"
  end
end
