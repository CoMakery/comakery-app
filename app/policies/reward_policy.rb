class RewardPolicy < ApplicationPolicy
  attr_reader :account, :reward

  def initialize(account, reward)
    @account = account
    @reward = reward
  end

  def new?
    @reward.project.owner_account == @account
  end
end
