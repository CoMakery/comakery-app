class RewardsController < ApplicationController
  before_filter :assign_project

  def create
    reward = Reward.new(reward_params.merge(issuer: current_account))
    authorize reward
    reward.save!
    flash[:notice] = "Successfully sent reward to #{reward.account.name}"
    current_account.send_reward_notifications(reward: reward)
    redirect_to project_path(@project)
  end

  private

  def reward_params
    params.require(:reward).permit(:account_id, :reward_type_id, :description)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
