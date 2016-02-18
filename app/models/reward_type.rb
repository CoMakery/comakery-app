class RewardType < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project, :name, :suggested_amount

  def self.invalid_params(attributes)
    attributes['name'].blank? || attributes['suggested_amount'].blank?
  end
end
