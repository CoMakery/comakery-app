class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      Account.joins(:authentications).where("authentications.slack_team_id = ?", account.slack_auth.slack_team_id)
    end
  end

  def new?
    Rails.application.config.allow_signup
  end
  alias_method :create?, :new?

  def edit?
    admin? || user == record
  end
  alias_method :update?, :edit?
  alias_method :show?, :edit?

  def destroy?
    admin?
  end
end
