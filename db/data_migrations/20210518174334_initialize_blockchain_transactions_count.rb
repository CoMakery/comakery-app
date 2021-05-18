class InitializeBlockchainTransactionsCount < ActiveRecord::DataMigration
  def up
    Award.find_each(&:set_counter_cache)
  end
end
