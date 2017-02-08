class RevenueDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def amount_pretty
    "#{currency_denomination}#{number_with_precision(amount, precision: 2, delimiter: ',')}"
  end

  def currency_denomination
    Comakery::Currency::DENOMINATIONS[currency]
  end
end