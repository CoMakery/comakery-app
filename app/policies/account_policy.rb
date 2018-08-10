class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      return Account.none unless @scope && @account
      @scope.accounts
    end
  end

  def new?
    Rails.application.config.allow_signup
  end
  alias create? new?

  def edit?
    user == record
  end
  alias update? edit?
  alias show? edit?
end
