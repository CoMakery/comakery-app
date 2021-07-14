class Projects::Transfers::SettingsController < ApplicationController
  def show
    @transfer = Award.find(params[:transfer_id])

    @project = @transfer.project

    authorize(@project, :edit?)
  end
end
