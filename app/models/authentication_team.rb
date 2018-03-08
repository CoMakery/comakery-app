class AuthenticationTeam < ApplicationRecord
  belongs_to :authentication
  has_one :account, through: :authentication
  has_many :projects, through: :account

  validates :authentication_id, presence: true
  validates :provider_team_id,  presence: true
end
