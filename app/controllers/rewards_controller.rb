class RewardsController < ApplicationController
  def create
    reward = Reward.new(reward_params.merge(issuer: current_account))
    redirect_to project_path(reward.reward_type.project)

    authorize reward
    reward.save!

    flash[:notice] = "Successfully sent reward to #{reward.account.name}"
    current_account.send_reward_notifications(reward: reward)
  rescue
    flash[:error] = "Failed sending reward to #{reward.account.name}"
  end

  private

  def reward_params
    params.require(:reward).permit(:account_id, :reward_type_id, :description)
  end
end
