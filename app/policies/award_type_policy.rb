class AwardTypePolicy < ApplicationPolicy
  attr_reader :account, :award_type

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, project_owner, scope)
      @account = account
      @project_owner = project_owner
      @scope = scope
    end

    def resolve
      if @account == @project_owner
        scope.all
      else
        scope.where.not(state: :draft)
      end
    end
  end
end
