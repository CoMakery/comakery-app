class ProjectRolePolicy < ApplicationPolicy
  def initialize(account, project_role)
    @account = account
    @project_role = project_role
  end

  def update?
    account.present? && project_admin? && !own_project_role?
  end

  private

    attr_reader :account, :project_role

    def project_admin?
      ProjectPolicy.new(account, project_role.project).project_admin?
    end

    def own_project_role?
      project_role.account == account
    end
end
