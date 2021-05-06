class InterestsController < ApplicationController
  before_action :authorize_project
  skip_before_action :verify_authenticity_token

  # POST /projects/1/interests
  def create
    @interest = current_account.interests.create(
      specialty: specialty || current_account.specialty,
      project: project
    )

    if @interest.save
      head 200
    else
      head 400
    end
  end

  # DELETE /projects/1/interests/1
  def destroy
    current_account.interests.where(project: project).destroy_all

    head 200
  end

  private

    def project
      @project ||= @project_scope.find(params[:project_id])
    end

    def specialty
      @specialty ||= Specialty.find_by(id: params[:specialty_id])
    end

    def authorize_project
      authorize project, :show?
    end
end
