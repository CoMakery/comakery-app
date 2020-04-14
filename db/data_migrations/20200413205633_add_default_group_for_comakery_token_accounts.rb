# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class AddDefaultGroupForComakeryTokenAccounts < ActiveRecord::DataMigration
  def up
    Token.coin_type_comakery.find_each(&:default_reg_group)

    AccountTokenRecord.where(reg_group_id: nil).find_each do |a|
      a.update_column(:reg_group_id, RegGroup.default_for(a.token).id)
    end
  end
end
