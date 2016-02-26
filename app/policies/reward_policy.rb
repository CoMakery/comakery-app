class RewardPolicy < ApplicationPolicy
  attr_reader :account, :reward

  def initialize(account, reward)
    @account = account
    @reward = reward
  end

  def create?
    project = @reward&.reward_type&.project
    @account && @account == project&.owner_account && project.slack_team_id == @reward&.account&.slack_auth&.slack_team_id
  end
end
