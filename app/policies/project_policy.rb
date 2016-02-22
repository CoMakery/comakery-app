class ProjectPolicy < ApplicationPolicy
  attr_reader :account, :project

  def initialize(account, project)
    @account = account
    @project = project
  end

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      projects = Project.arel_table
      scope.where(projects[:public].eq(true).or(projects[:slack_team_id].in(@account.authentications.pluck(:slack_team_id))))
    end
  end

  def show?
    account.present? && (project.public? || account.authentications.pluck(:slack_team_id).include?(project.slack_team_id))
  end

  def edit?
    account.present? && account.authentications.pluck(:slack_team_id).include?(project.slack_team_id)
  end
  alias :update? :edit?
end
