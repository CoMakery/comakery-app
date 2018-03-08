class Team < ApplicationRecord
  has_many :account_teams, dependent: :destroy
  has_many :accounts, through: :account_teams
end
