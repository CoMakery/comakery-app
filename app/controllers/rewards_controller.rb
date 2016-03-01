class RewardsController < ApplicationController
  def index
    @project = policy_scope(Project).find(params[:project_id])
    @rewards = policy_scope(Reward)
  end

  def create
    reward = Reward.new(reward_params.merge(issuer: current_account))
    authorize reward
    reward.save!
    flash[:notice] = "Successfully sent reward to @#{reward.recipient_slack_user_name}"
    current_account.send_reward_notifications(reward: reward)
    redirect_to project_rewards_path(reward.reward_type.project)
  rescue Pundit::NotAuthorizedError
    flash[:error] = "Failed sending reward"
    redirect_to(:back)
  end

  private

  def reward_params
    params.require(:reward).permit(:account_id, :reward_type_id, :description)
  end
end
