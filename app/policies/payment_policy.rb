class PaymentPolicy < ApplicationPolicy
  attr_reader :account, :payment

  def initialize(account, payment)
    @account = account
    @auth = account&.slack_auth
    @payment = payment
  end

  def create?
    @auth.present? &&
      @payment.project.awards.where(authentication_id: @auth.id).present?
  end

  def update?
    @payment.project &&
      ProjectPolicy.new(@account, @payment.project).update?
  end
end
