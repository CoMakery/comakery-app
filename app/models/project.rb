class Project < ActiveRecord::Base
  has_many :reward_types, inverse_of: :project
  accepts_nested_attributes_for :reward_types, reject_if: :invalid_params

  def invalid_params(attributes)
    RewardType.invalid_params(attributes)
  end
end
