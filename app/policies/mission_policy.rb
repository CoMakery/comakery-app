class MissionPolicy < ApplicationPolicy
  attr_reader :account, :mission

  def initialize(account, mission)
    @account = account
    @mission = mission
  end

  class Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      if account&.comakery_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def show?
    true
  end

  def new?
    @account.comakery_admin?
  end

  alias index? new?
  alias create? new?
  alias edit? new?
  alias update? new?
  alias destroy? new?
  alias rearrange? new?
end
