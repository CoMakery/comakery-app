class AuthenticationPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      return Authentication.none unless account
      Authentication.where(slack_team_id: account.slack_auth.slack_team_id)
    end
  end
end

