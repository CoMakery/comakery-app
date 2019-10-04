class Dashboard::TransfersController < ApplicationController
  before_action :assign_project
  before_action :set_transfers, only: [:index]
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  def index
    authorize @project, :transfers?
  end

  def create; end

  def update; end

  private

    def set_transfers
      @page = (params[:page] || 1).to_i
      @q = @project.awards.completed.ransack(params[:q])
      @transfers = @q.result.includes(:account, :issuer, :project, :award_type, :token).page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @transfers.out_of_range?
    end
end
