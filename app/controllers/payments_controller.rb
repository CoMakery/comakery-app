class PaymentsController < ApplicationController
  before_filter :assign_project, :assign_current_auth
  skip_before_filter :require_login, only: :index

  def index
    authorize @project, :show_revenue_info?

    @payment = @project.payments.new
  end

  def create
    authorize @project

    @payment = @project.payments.new_with_quantity quantity_redeemed: payment_params['quantity_redeemed'],
                                                   payee_auth: @current_auth

    if @payment.save
      redirect_to project_payments_path(@project)
    else
      render template: 'payments/index'
    end
  end

  private
  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end

  def assign_current_auth
    @current_auth = current_account&.slack_auth&.decorate
  end

  def payment_params
    params.require(:payment).permit :quantity_redeemed
  end
end