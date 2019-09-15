class Dashboard::TransfersController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  def index
    authorize @project, :transfers?
  end

  def create; end

  def update; end
end
