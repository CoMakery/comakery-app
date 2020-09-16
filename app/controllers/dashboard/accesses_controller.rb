class Dashboard::AccessesController < ApplicationController
  before_action :assign_project
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :accesses?

    @admins = @project.admins
  end

  def add_admin
    authorize @project
    account = Account.find_by(email: params[:email])

    return redirect_to project_dashboard_accesses_path(@project), flash: { error: 'Account is not found on CoMakery' } unless account

    return redirect_to project_dashboard_accesses_path(@project), flash: { error: 'Project owner cannot be added as a project admin' } if @project.account == account

    return redirect_to project_dashboard_accesses_path(@project), flash: { error: "#{account.decorate.name} is already a project admin" } if @project.admins.include?(account)

    @project.admins << account
    @project.interested << account unless account.interested?(@project.id)
    redirect_to project_dashboard_accesses_path(@project), notice: "#{account.decorate.name} added as a project admin"
  end

  def remove_admin
    authorize @project

    account = Account.find_by(id: params[:account_id])

    if account && @project.admins.include?(account)
      @project.admins.delete(account)
      redirect_to project_dashboard_accesses_path(@project), notice: "#{account.decorate.name} removed from project admins"
    else
      redirect_to project_dashboard_accesses_path(@project), flash: { error: 'Project admin is not found' }
    end
  end

  def regenerate_api_key
    authorize @project

    @project.regenerate_api_key

    redirect_to project_dashboard_accesses_path(@project), notice: 'API key has been regenerated'
  end
end
