class AuthenticationPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :account, :team

    def initialize(account, team)
      @account = account
      @team = team
    end

    def resolve
      return Authentication.none unless account && team
      team.authentications
    end
  end
end
