class PopulateStateForAwardTypes < ActiveRecord::DataMigration
  def up
    AwardType.all.each do |award_type|
      award_type.update(state: award_type.published? ? :public : :draft)
    end
  end
end
