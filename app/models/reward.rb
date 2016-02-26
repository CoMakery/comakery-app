class Reward < ActiveRecord::Base
  belongs_to :account
  belongs_to :issuer, class_name: Account
  belongs_to :reward_type

  validates_presence_of :account, :issuer, :reward_type
end
