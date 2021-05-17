class ProjectRolePolicy < ApplicationPolicy
  def initialize(account, project_role)
    @account = account
    @project_role = project_role
  end

  def update?
    return false if account.nil? || project_role.account == account

    case project_role.role.to_sym
    when :admin
      project_owner?
    when :interested, :observer
      project_owner? || project_admin?
    else
      raise "Unimplemented role #{project_role.role}"
    end
  end

  private

    attr_reader :account, :project_role

    def project_admin?
      ProjectPolicy.new(account, project_role.project).project_admin?
    end

    def project_owner?
      ProjectPolicy.new(account, project_role.project).project_owner?
    end
end
