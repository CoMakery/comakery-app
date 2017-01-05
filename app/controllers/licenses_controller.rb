class LicensesController < ApplicationController
  before_filter :assign_project, only: :index
  skip_before_filter :require_login, only: :index

  def index
  end

  private
  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end
end