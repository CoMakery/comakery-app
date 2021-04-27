class Projects::InvitesController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped

  before_action :find_project

  def create
    authorize @project, :add_person?

    send_invite_result = SendInvite.call(project: @project, params: params)

    respond_to do |format|
      if send_invite_result.success?
        format.json { render json: { message: 'Invite successfully sent' }, status: :created }
      else
        format.json { render json: { errors: send_invite_result.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

    def find_project
      @project = Project.find(params[:project_id])
    end
end
