class Team < ApplicationRecord
  has_many :authentication_teams, dependent: :destroy
  has_many :accounts, through: :authentication_teams

  def build_authentication_team authentication
    authentication_teams.create authentication: authentication, account: authentication.account
  end
end
