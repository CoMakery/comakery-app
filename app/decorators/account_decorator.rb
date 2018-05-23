class AccountDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def name
    return nickname if nickname.present?
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def nick
    nickname || name
  end

  def total_awards_earned_pretty(project)
    pretty_award total_awards_earned(project)
  end

  def total_awards_remaining_pretty(project)
    pretty_award total_awards_remaining(project)
  end

  def total_revenue_unpaid_remaining_pretty(project)
    pretty_currency(project, total_revenue_unpaid(project))
  end

  def total_revenue_paid_pretty(project)
    pretty_currency(project, total_revenue_paid(project))
  end

  def percentage_of_unpaid_pretty(project)
    "#{number_with_precision(percent_unpaid(project).truncate(1), precision: 1)}%"
  end

  private

  def pretty_currency(project, amount_to_make_pretty)
    precision = Comakery::Currency::PRECISION[project.denomination]
    denomination = Comakery::Currency::DENOMINATIONS[project.denomination]
    "#{denomination}#{number_with_precision(amount_to_make_pretty.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def pretty_award(award_amount_to_make_pretty)
    number_with_precision(award_amount_to_make_pretty, precision: 0, delimiter: ',')
  end
end
