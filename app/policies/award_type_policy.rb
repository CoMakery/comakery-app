class AwardTypePolicy < ApplicationPolicy
  attr_reader :account, :award_type

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, project, scope)
      @account = account
      @scope = scope
      @project_editable = ProjectPolicy.new(account, project).edit?
    end

    def resolve
      if @project_editable
        scope.all
      else
        scope.where.not(state: :draft)
      end
    end
  end
end
