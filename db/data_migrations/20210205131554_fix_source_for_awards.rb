class FixSourceForAwards < ActiveRecord::DataMigration
  def up
    Award.find_each do |award|
      award.update(:source, Award.sources[award.transfer_type.name.to_sym] || 0)
    end
  end
end
