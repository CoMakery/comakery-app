class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      return Account.none unless account
      Account.joins(:authentications).where('authentications.slack_team_id = ?', account.slack_auth.slack_team_id)
    end
  end

  def new?
    Rails.application.config.allow_signup
  end
  alias create? new?

  def edit?
    admin? || user == record
  end
  alias update? edit?
  alias show? edit?

  def destroy?
    admin?
  end
end
