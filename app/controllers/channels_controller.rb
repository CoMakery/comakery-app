class ChannelsController < ApplicationController
  

  def users
    channel = current_account.channels.find params[:id]
    @members = channel.members(current_account)
    respond_to do |format|
      format.js { render layout: false }
    end
  end
end
