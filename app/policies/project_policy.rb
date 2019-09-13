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
    project.public_listed? || (team_member? && project.unarchived?) || edit?
  end

  def unlisted?
    project.public_unlisted? || (team_member? && project.unarchived?) || edit?
  end

  def edit?
    account.present? && project_owner?
  end

  alias update? edit?
  alias send_award? edit?
  alias admins? edit?
  alias add_admin? edit?
  alias remove_admin? edit?

  def show_contributions?
    (project.public? && !project.require_confidentiality?) ||
      team_member?
  end

  def show_award_types?
    show? || unlisted?
  end

  def project_owner?
    account&.owned_project?(project)
  end

  def team_member?
    account&.same_team_or_owned_project?(project)
  end

  def update_status?
    account.comakery_admin?
  end

  alias send_community_award? team_member?
end
