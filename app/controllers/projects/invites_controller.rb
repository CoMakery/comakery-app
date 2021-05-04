class Projects::InvitesController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped

  def create
    authorize(project, :project_admin?)

    send_invite_result = SendInvite.call(project: project, whitelable_mission: @whitelabel_mission, params: params)

    respond_to do |format|
      if send_invite_result.success?
        format.json { render json: { message: 'Invite successfully sent' }, status: :created }
      else
        format.json { render json: { errors: send_invite_result.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

    def project
      @project ||= @project_scope.find(params[:project_id])
    end
end
