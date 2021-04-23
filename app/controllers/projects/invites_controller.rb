class Projects::InvitesController < ApplicationController
  before_action :find_project

  def create
    authorize @project, :add_person?

    @invite = @project.interests.new(
      account: Account.find_by(email: params[:email]),
      role: params[:role]
    )

    respond_to do |format|
      if @invite.save
        format.js { render status: :created }
      else
        format.js { render status: :unprocessable_entity }
      end
    end
  end

  private

    def find_project
      @project = Project.find(params[:project_id])
    end
end
