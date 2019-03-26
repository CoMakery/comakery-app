class AwardTypeDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def description_markdown
    Comakery::Markdown.to_html(award_type.description)
  end
end
