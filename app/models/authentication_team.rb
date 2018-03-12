class AuthenticationTeam < ApplicationRecord
  belongs_to :authentication
  belongs_to :account
  belongs_to :team
  has_many :projects, through: :account
  validates :account, :team, :authentication, presence: true
end
