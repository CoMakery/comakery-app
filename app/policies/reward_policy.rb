class RewardPolicy < ApplicationPolicy
  attr_reader :account, :reward

  def initialize(account, reward)
    @account = account
    @reward = reward
  end

  def create?
    @account && @account == @reward&.reward_type&.project&.owner_account
  end
end
