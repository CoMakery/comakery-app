class MoveAccountSpecialtyToReference < ActiveRecord::DataMigration
  def up
    Account.where.not(deprecated_specialty: nil).where(specialty: nil).each do |account|
      account.update(specialty: Specialty.find_by(name: Account.deprecated_specialties[account.deprecated_specialty]))
    end
  end
end
