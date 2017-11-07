class Payment < ApplicationRecord
  nilify_blanks

  belongs_to :project
  belongs_to :issuer, class_name: 'Authentication'
  belongs_to :payee, class_name: 'Authentication'

  validates :project, :payee, :total_value, :share_value, :quantity_redeemed, :currency, presence: true
  validates :quantity_redeemed, numericality: { greater_than_or_equal_to: 0 }
  validates :total_payment, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  validate :payee_has_the_awards_they_are_redeeming
  validate :must_use_the_precision_of_the_currency_for_total_payment
  validate :must_use_the_precision_of_the_currency_for_total_value
  validate :check_total_value_calculation
  validate :check_total_payment_calculation
  validate :check_minimum_payment

  scope :total_awards_redeemed, -> { sum(:quantity_redeemed) }
  scope :total_value_redeemed, -> { sum(:total_value) }

  def truncate_total_value_to_currency_precision
    return if total_value.blank?
    self.total_value = total_value.truncate(currency_precision)
  end

  private

  def payee_has_the_awards_they_are_redeeming
    return unless payee.present? && project.present? && quantity_redeemed.present?
    new_amount_redeemed = quantity_redeemed_was.present? ? (quantity_redeemed - quantity_redeemed_was) : quantity_redeemed

    if (payee.total_awards_paid(project) + new_amount_redeemed) > payee.total_awards_earned(project)
      errors.add(:quantity_redeemed, "cannot be greater than the payee's total awards remaining balance")
    end
  end

  def must_use_the_precision_of_the_currency_for_total_payment
    return if total_payment.nil? || currency_precision.nil?
    if total_payment.truncate(currency_precision) != total_payment
      errors.add(:total_payment, "must use only #{currency_precision} decimal places for #{currency}")
    end
  end

  def must_use_the_precision_of_the_currency_for_total_value
    return if total_value.nil? || currency_precision.nil?
    if total_value.truncate(currency_precision) != total_value
      errors.add(:total_value, "must use only #{currency_precision} decimal places for #{currency}")
    end
  end

  def check_total_value_calculation
    return if total_value.nil? || quantity_redeemed.nil?
    return if (share_value * quantity_redeemed).truncate(currency_precision) == total_value
    errors.add(:total_value, "#{total_value} does not match the quantity #{quantity_redeemed}" \
        " and share value #{share_value}")
  end

  def check_total_payment_calculation
    return if total_payment.nil? || transaction_fee.nil?
    return if total_payment + transaction_fee == total_value
    errors.add(:total_payment, 'is not equal to the total value minus the transaction fee')
  end

  def check_minimum_payment
    return if total_value.blank? || currency.blank? || total_value >= min_payment
    errors.add(:total_value, "must be greater than or equal to #{currency_symbol}#{min_payment}")
  end

  def min_payment
    Comakery::Currency::DEFAULT_MIN_PAYMENT[currency]
  end

  def currency_symbol
    Comakery::Currency::DENOMINATIONS[currency]
  end

  def currency_precision
    Comakery::Currency::PRECISION[currency]
  end
end
