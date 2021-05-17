class InitializeBlockchainTransactionsCount < ActiveRecord::Migration[6.0]
  def up
    Award.find_each { |award| award.set_counter_cache }
  end

  def down
  end
end
