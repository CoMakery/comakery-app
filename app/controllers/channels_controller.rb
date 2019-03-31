class ChannelsController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped

  def users
    channel = current_account.channels.find params[:id]
    @members = channel.members
    respond_to do |format|
      format.js { render layout: false }
    end
  end
end
