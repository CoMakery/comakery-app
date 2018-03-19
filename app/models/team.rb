class Team < ApplicationRecord
  has_many :authentication_teams, dependent: :destroy
  has_many :accounts, through: :authentication_teams
  has_many :projects, -> { distinct }, through: :authentication_teams

  def build_authentication_team(authentication)
    authentication_teams.find_or_create_by authentication: authentication, account: authentication.account
  end

  def authentication_team_by_account(account)
    authentication_teams.find_by account_id: account.id
  end
end
