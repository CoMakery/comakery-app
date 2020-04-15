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
        account.accessable_projects(scope)
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
    account.present? && (project_owner? || project_admin?)
  end

  def show_contributions_to_everyone?
    project.public? && !project.require_confidentiality?
  end

  def show_contributions_to_team?
    team_member? && project.unarchived? && !project.require_confidentiality?
  end

  def show_contributions?
    show_contributions_to_everyone? || show_contributions_to_team? || edit?
  end

  def show_award_types?
    show? || unlisted?
  end

  def show_transfer_rules?
    show_contributions? && project.supports_transfer_rules?
  end

  alias update? edit?
  alias send_award? edit?
  alias admins? edit?
  alias add_admin? edit?
  alias remove_admin? edit?
  alias create_transfer? edit?
  alias transfers? show_contributions?
  alias accounts? show_contributions?
  alias edit_accounts? edit?
  alias edit_reg_groups? edit?
  alias edit_transfer_rules? edit?
  alias freeze_token? edit?

  def project_owner?
    account.present? && (project.account == account)
  end

  def project_admin?
    account.present? && (project.admins.include? account)
  end

  def team_member?
    account&.same_team_or_owned_project?(project) || edit?
  end

  def update_status?
    account.comakery_admin?
  end
end
