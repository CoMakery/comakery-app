class TokenOptInPolicy < ApplicationPolicy
  attr_reader :token_opt_in, :account

  def initialize(account, token_opt_in)
    @account = account
    @token_opt_in = token_opt_in
  end

  def create?
    @token_opt_in.token._token_type_asa? &&
    @account&.wallets&.where(id: @token_opt_in.wallet_id)&.exists?
  end

  def pay?
    true
  end
end
