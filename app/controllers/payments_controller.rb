class PaymentsController < ApplicationController
  before_action :assign_project, :assign_current_auth
  skip_before_action :require_login, only: :index

  def index
    authorize @project, :show_revenue_info?

    @payment = @project.payments.new
  end

  def create
    authorize @project

    payment_params = params.require(:payment).permit :quantity_redeemed

    @payment = @project.payments.new_with_quantity quantity_redeemed: payment_params[:quantity_redeemed], account: current_account
    @payment.truncate_total_value_to_currency_precision

    authorize @payment, :create?

    if @payment.save
      flash[:notice] = "#{@payment.decorate.total_value_pretty} pending payment by the project owner."
      redirect_to project_payments_path(@project)
    else
      render template: 'payments/index'
    end
  end

  def update
    authorize @project # TODO: scope to project owner

    update_params = params.require(:payment).permit :transaction_fee, :transaction_reference, :id
    @payment = current_account.payments.find(params['id'])

    authorize @payment, :update?

    @payment.transaction_fee = update_params[:transaction_fee]
    @payment.transaction_reference = update_params[:transaction_reference]
    @payment.transaction_fee ||= 0
    @payment.total_payment = @payment.total_value - @payment.transaction_fee
    @payment.reconciled = true

    flash[:error] = @payment.errors.full_messages.join(' ') unless @payment.save

    redirect_to project_payments_path(@project)
  end

  private

  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end

  def assign_current_auth
    @current_auth = current_account&.slack_auth&.decorate
  end
end
