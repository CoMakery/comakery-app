class WalletPolicy < ApplicationPolicy
  attr_reader :account, :wallet

  def initialize(account, wallet)
    @account = account
    @wallet = wallet
  end

  class Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      if account
        account.wallets
      else
        scope.none
      end
    end
  end

  def new?
    account.present?
  end

  def show?
    account == wallet.account
  end

  alias index? new?
  alias create? show?
  alias algorand_opt_ins? show?
  alias edit? show?
  alias update? show?
  alias destroy? show?
end
