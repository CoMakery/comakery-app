class PaymentDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def total_value_pretty
    "#{currency_symbol}#{number_with_precision(total_value.truncate(Comakery::Currency::PRECISION[currency]),
      precision: Comakery::Currency::PRECISION[currency],
      delimiter: ',')}"
  end

  def share_value_pretty
    precision = Comakery::Currency::PER_SHARE_PRECISION[currency]
    "#{currency_symbol}#{number_with_precision(share_value.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def total_payment_pretty
    return if total_payment.blank?
    "#{currency_symbol}#{number_with_precision(total_payment.truncate(Comakery::Currency::PRECISION[currency]),
      precision: Comakery::Currency::PRECISION[currency],
      delimiter: ',')}"
  end

  def transaction_fee_pretty
    return if transaction_fee.blank?
    "#{currency_symbol}#{number_with_precision(transaction_fee.truncate(Comakery::Currency::PRECISION[currency]),
      precision: Comakery::Currency::PRECISION[currency],
      delimiter: ',')}"
  end

  def currency_symbol
    Comakery::Currency::DENOMINATIONS[currency]
  end

  def payee_name
    payee.display_name
  end

  def status
    reconciled ? 'Paid' : 'Unpaid'
  end

  def payee_avatar
    payee.slack_icon
  end

  def issuer_name
    issuer.display_name if issuer&.display_name
  end

  def issuer_avatar
    issuer.slack_icon if issuer&.slack_icon
  end
end
