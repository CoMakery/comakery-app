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

      scope.where(projects[:public].eq(true).or(projects[:owner_account_id].eq(account.id)))
    end
  end

  def allow?
    account.present? && (project.public? || project.owner_account_id == account.try(:id))
  end
  alias :edit? :allow?
  alias :show? :allow?
  alias :update? :allow?
end
