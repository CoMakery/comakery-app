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
    account.decorate.name
  end

  def status
    reconciled ? 'Paid' : 'Unpaid'
  end

  def payee_avatar
    account.image
  end

  def issuer_name
    issuer&.decorate&.name
  end

  def issuer_avatar
    issuer&.image
  end
end
