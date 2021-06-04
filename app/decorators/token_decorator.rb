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

  def explorer_human_url
    return if contract_address.blank?

    blockchain.url_for_token_human(contract_address)
  end

  def trancated_address
    return if contract_address.blank?

    h.middle_truncate(contract_address)
  end
end
