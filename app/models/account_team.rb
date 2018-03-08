class AccountTeam < ApplicationRecord
  belongs_to :account
  belongs_to :team
  has_many :projects, through: :account

  validates :account, :team, presence: true
end
