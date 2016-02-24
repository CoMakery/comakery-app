class Project < ActiveRecord::Base
  has_many :reward_types, inverse_of: :project, dependent: :destroy
  accepts_nested_attributes_for :reward_types, reject_if: :invalid_params, allow_destroy: true

  has_many :rewards, inverse_of: :project, dependent: :destroy

  belongs_to :owner_account, class_name: Account
  validates_presence_of :owner_account

  def invalid_params(attributes)
    RewardType.invalid_params(attributes)
  end
end
