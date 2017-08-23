class LicensesController < ApplicationController
  before_action :assign_project, only: :index
  skip_before_action :require_login, only: :index

  def index; end

  private

  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end
end
