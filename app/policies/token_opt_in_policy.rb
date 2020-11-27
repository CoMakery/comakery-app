class TokenOptInPolicy < ApplicationPolicy
  attr_reader :token_opt_in, :account

  def initialize(account, token_opt_in)
    @account = account
    @token_opt_in = token_opt_in
  end

  def create?
    @token_opt_in.valid?
  end
end
