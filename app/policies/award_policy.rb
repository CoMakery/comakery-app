class AwardPolicy < ApplicationPolicy
  attr_reader :account, :award

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      if account
        scope.joins(award_type: :project).where("projects.slack_team_id = ?", @account.slack_auth.slack_team_id)
      else
        scope.joins(award_type: :project).where("projects.public = ?", true)
      end
    end
  end

  def initialize(account, award)
    @account = account
    @award = award
  end

  def create?
    project = @award&.award_type&.project
    @account &&
        @award.issuer == @account &&
        (@account == project&.owner_account || (@award&.award_type&.community_awardable? && @account != @award&.account)) &&
        @award&.account&.authentications&.pluck(:slack_team_id).include?(project.slack_team_id) &&
        @award&.issuer&.authentications&.pluck(:slack_team_id).include?(project.slack_team_id)
  end
end
