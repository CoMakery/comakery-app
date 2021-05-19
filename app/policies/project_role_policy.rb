class ProjectRolePolicy < ApplicationPolicy
  def initialize(account, project_role)
    @account = account
    @project_role = project_role
  end

  def update?
    return false if account.nil? || project_role.account == account

    case project_role.role.to_sym
    when :admin      then can_edit_admin_role?
    when :interested then can_edit_interested_role?
    when :observer   then can_edit_observer_role?
    else raise "Unimplemented role #{project_role.role}"
    end
  end

  private

    attr_reader :account, :project_role

    def project_owner?
      ProjectPolicy.new(account, project_role.project).project_owner?
    end

    alias can_edit_admin_role? project_owner?

    def project_admin?
      ProjectPolicy.new(account, project_role.project).project_admin?
    end

    def can_edit_interested_role?
      project_owner? || project_admin?
    end

    def can_edit_observer_role?
      project_owner? || project_admin?
    end
end
