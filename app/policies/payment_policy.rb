class PaymentPolicy < ApplicationPolicy
  attr_reader :account, :payment

  def initialize(account, payment)
    @account = account
    @payment = payment
  end

  def create?
    @account.present? &&
      @payment.project.awards.where(account_id: @account.id).present?
  end

  def update?
    @payment.project &&
      ProjectPolicy.new(@account, @payment.project).update?
  end
end
