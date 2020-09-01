class Team < ApplicationRecord
  has_many :authentication_teams, dependent: :destroy
  has_many :accounts, through: :authentication_teams
  has_many :authentications, through: :authentication_teams
  has_many :channels # rubocop:todo Rails/HasManyOrHasOneDependent
  has_many :projects, -> { distinct }, through: :channels

  def build_authentication_team(authentication, manager = false)
    auth_team = authentication_teams.find_or_create_by authentication: authentication, account: authentication.account
    auth_team.update manager: manager
  end

  def authentication_team_by_account(account)
    authentication_teams.find_by account_id: account.id
  end

  def members
    return [] unless discord?

    d_client = Comakery::Discord.new
    @members ||= d_client.members(self)
  end

  def members_for_select
    members.map { |m| [m['user']['username'], m['user']['id']] }
  end

  def discord?
    provider == 'discord'
  end

  def slack?
    provider == 'slack'
  end
end
