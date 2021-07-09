class Projects::Transfers::SettingsController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_action :project, :transfer, only: [:show]

  def show; end

  private

    def project
      @project ||= transfer.project
    end

    def transfer
      @transfer ||= Award.find(params[:transfer_id])
    end
end
