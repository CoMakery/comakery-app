class TokenPolicy < ApplicationPolicy
  attr_reader :account, :token

  def initialize(account, project)
    @account = account
    @project = project
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

  def new?
    account&.comakery_admin?
  end

  alias create? new?
  alias index? new?
  alias show? new?
  alias edit? new?
  alias update? new?
end
