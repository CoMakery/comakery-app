class AuthenticationTeam < ApplicationRecord
  belongs_to :authentication

  validates :authentication_id, presence: true
  validates :provider_team_id,  presence: true
end
