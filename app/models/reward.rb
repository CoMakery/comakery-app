class Reward < ActiveRecord::Base
  belongs_to :account
  belongs_to :issuer, class_name: Account
  belongs_to :project

  validates_presence_of :account, :project, :issuer, :amount
end
