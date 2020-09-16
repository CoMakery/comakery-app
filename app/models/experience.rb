class Experience < ApplicationRecord
  belongs_to :account
  belongs_to :specialty

  def self.increment_for(account, specialty)
    Experience.find_or_create_by(account: account, specialty: specialty).increment(:level).save

    Experience.increment_for(account, Specialty.find_or_create_by(name: 'General')) if specialty.name != 'General'
  end
end
