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
      if @account && @account.slack_auth
        projects = Project.arel_table
        scope.where(projects[:public].eq(true).or(projects[:id].in(@account.team_projects.map(&:id))))
      else
        scope.where(public: true)
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
    project.share_revenue? && show_contributions?
  end

  def team_member?
    account.team_projects.include?(project)
  end

  alias send_community_award? team_member?
end
