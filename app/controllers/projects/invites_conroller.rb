class Projects::InvitesController < ApplicationController
  before_action :find_project

  def create
  end

  private

    def invite_params
      params.require(:interest).permit(:email, :role)
    end
end
