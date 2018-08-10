class TeamsController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @teams = current_account.manager_teams.where(provider: params[:provider])
    elem_id = params[:elem_id]
    @elem_index = elem_id.split('_')[3] if elem_id

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def channels
    @auth_team = current_account.authentication_teams.find_by team_id: params[:id]
    @channels = @auth_team ? @auth_team.channels : []
    elem_id = params[:elem_id]
    @elem_index = elem_id.split('_')[3] if elem_id
    respond_to do |format|
      format.js { render layout: false }
    end
  end
end
