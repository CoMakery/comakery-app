class PopulateExpereinceTable < ActiveRecord::DataMigration
  def up
    Award.completed.where.not(account: nil).each do |award|
      Experience.increment_for(award.account, award.specialty)
    end
  end
end
