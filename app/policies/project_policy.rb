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
    project.public? || (team_member? && project.unarchived?) || edit?
  end

  alias index? show?

  def edit?
    account.present? && project_owner?
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

  def project_owner?
    account&.owned_project?(project)
  end

  def team_member?
    account&.same_team_or_owned_project?(project)
  end

  def unlisted?
    project&.can_be_access?(account)
  end

  def update_status?
    account.comakery_admin?
  end

  alias send_community_award? team_member?
end
