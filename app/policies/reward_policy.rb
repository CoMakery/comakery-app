class RewardPolicy < ApplicationPolicy
  attr_reader :account, :reward

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      scope.joins(reward_type: :project).where("projects.slack_team_id = ?", @account.slack_auth.slack_team_id)
    end
  end

  def initialize(account, reward)
    @account = account
    @reward = reward
  end

  def create?
    project = @reward&.reward_type&.project
    @account && @account == project&.owner_account && project.slack_team_id == @reward&.account&.slack_auth&.slack_team_id
  end
end
