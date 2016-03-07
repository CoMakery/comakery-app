class AwardPolicy < ApplicationPolicy
  attr_reader :account, :award

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      scope.joins(award_type: :project).where("projects.slack_team_id = ?", @account.slack_auth.slack_team_id)
    end
  end

  def initialize(account, award)
    @account = account
    @award = award
  end

  def create?
    project = @award&.award_type&.project
    @account && @account == project&.owner_account && project.slack_team_id == @award&.account&.slack_auth&.slack_team_id
  end
end
