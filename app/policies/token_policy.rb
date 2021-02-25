class TokenPolicy < ApplicationPolicy
  attr_reader :account, :token

  def initialize(account, token)
    @account = account
    @token = token
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
  alias fetch_contract_details? new?
end
