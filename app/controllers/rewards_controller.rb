class RewardsController < ApplicationController
  def index
    @project = policy_scope(Project).find(params[:project_id])
    @rewards = policy_scope(Reward)
  end

  def create
    result = RewardSlackUser.call(slack_user_id: params[:reward][:slack_user_id],
                                  issuer: current_account,
                                  reward_params: reward_params.except(:slack_user_id))
    unless result.success?
      fail_and_redirect(result.message)
      return
    end

    reward = result.reward
    authorize reward
    unless reward.save
      fail_and_redirect(reward.errors.full_messages.join(", "))
      return
    end

    flash[:notice] = "Successfully sent reward to #{reward.recipient_slack_user_name}"
    current_account.send_reward_notifications(reward: reward)
    redirect_to project_rewards_path(reward.reward_type.project)
  rescue Pundit::NotAuthorizedError
    fail_and_redirect("Not authorized")
  end

  def fail_and_redirect(message)
    skip_authorization
    flash[:error] = "Failed sending reward - #{message}"
    redirect_to(:back)
  end

  private

  def reward_params
    params.require(:reward).permit(:slack_user_id, :reward_type_id, :description)
  end
end
