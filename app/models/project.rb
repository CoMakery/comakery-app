class Project < ActiveRecord::Base
  has_many :reward_types
  accepts_nested_attributes_for :reward_types
end
