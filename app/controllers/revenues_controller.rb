class RevenuesController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: :index

  def index
    @revenue = @project.revenues.new
  end

  def create
    @revenue = @project.revenues.new(revenue_params)
    @revenue.currency = @project.denomination
    @revenue.recorded_by = current_account

    if @revenue.save
      redirect_to project_revenues_path(@project)
    else
      render template: 'revenues/index'
    end
  end

  private

  def assign_project
    project = Project.find(params[:project_id])
    @project = project.decorate if project.can_be_access?(current_account) && project.share_revenue?
    redirect_to root_path unless @project
  end

  def revenue_params
    params.require(:revenue).permit \
      :amount,
      :comment,
      :transaction_reference,
      :project_id
  end
end
