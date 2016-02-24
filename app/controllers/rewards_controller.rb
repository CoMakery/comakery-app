class RewardsController < ApplicationController
  before_filter :assign_project

  def new
    @rewardable_accounts = policy_scope(Account).all
    @reward = @project.rewards.build
    authorize @project
  end

  def create
    reward = @project.rewards.build(reward_params.merge(issuer: current_account))
    authorize reward
    reward.save!
    flash[:notice] = "Successfully sent reward to #{reward.account.name}"
    redirect_to project_path(@project)
  end

  private

  def reward_params
    params.require(:reward).permit(:account_id, :amount, :description)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
