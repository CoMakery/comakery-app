class AwardTypeDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def description_markdown
    Comakery::Markdown.to_html(award_type.description)
  end

  def amount_pretty
    number_with_precision(award_type.amount, precision: 0, delimiter: ',')
  end

  def name_with_amount
    "#{amount_pretty}  #{name}"
  end
end
