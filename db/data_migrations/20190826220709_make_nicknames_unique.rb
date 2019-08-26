# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class MakeNicknamesUnique < ActiveRecord::DataMigration
  def up
    Account.group(:nickname).count.select{ |value, count| value && count > 1 }.keys.each do |nickname|
      Account.where(nickname: nickname).each do |a|
        a.update_column(:nickname, "#{nickname} #{a.id}")
      end
    end
  end
end