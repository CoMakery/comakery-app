class Projects::Transfers::SettingsController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped

  def show
    @transfer = Award.find(params[:transfer_id])

    @project = @transfer.project
  end
end
