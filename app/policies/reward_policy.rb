class RewardPolicy < ApplicationPolicy
  attr_reader :account, :reward

  def initialize(account, reward)
    @account = account
    @reward = reward
  end

  def create?
    # project = @reward&.reward_type&.project
    # @account &&
    # project&.owner_account == @account &&
    # project&.accounts&.include?(reward.account) &&
    # project.reward_types.include?(reward.reward_type)
    #
    @account && @reward&.reward_type&.project&.owner_account == @account
  end
end
