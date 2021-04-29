class TokenDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def currency_denomination
    Comakery::Currency::DENOMINATIONS[token.denomination]
  end

  def network
    _blockchain
  end

  def logo_url(host: Rails.application.routes.default_url_options[:host])
    Rails.application.routes.url_helpers.polymorphic_url(logo_image, host: host) if logo_image&.attached?
  end
end
