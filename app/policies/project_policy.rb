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
      if account
        projects = Project.arel_table
        scope.where(projects[:public].eq(true).or(projects[:slack_team_id].in(@account.authentications.pluck(:slack_team_id))))
      else
        scope.where(public: true)
      end
    end
  end

  def show?
    project.public? || account.present? && account.authentications.pluck(:slack_team_id).include?(project.slack_team_id)
  end
  alias :index? :show?

  def edit?
    account.present? && project.owner_account == account
  end
  alias :update? :edit?
  alias :send_award? :edit?
end
