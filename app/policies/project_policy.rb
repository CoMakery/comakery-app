class ProjectPolicy < ApplicationPolicy
  attr_reader :account

  def initialize(account)
    @account = account
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

  # def index?
  #   user.admin? or not post.published?
  # end
end
