class AddStatusToAwards < ActiveRecord::DataMigration
  def up
    Award.where(status: nil).each do |award|
      award.update(status: (award.ethereum_transaction_address ? 'paid' : 'accepted'))
    end
  end
end
