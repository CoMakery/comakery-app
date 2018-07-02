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
      if @account
        account.accessable_projects
      else
        scope.publics
      end
    end
  end

  def show?
    project.public? || team_member?
  end

  alias index? show?

  def edit?
    account.present? && project.account == account
  end

  alias update? edit?
  alias send_award? edit?

  def show_contributions?
    (project.public? && !project.require_confidentiality?) ||
      team_member?
  end

  def show_revenue_info?
    project.show_revenue_info?(account)
  end

  def team_member?
    account == project.account || account&.same_team_project?(project)
  end

  def unlisted?
    project&.can_be_access?(account)
  end

  alias send_community_award? team_member?
end
