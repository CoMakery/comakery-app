class TokenDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def ethereum_contract_explorer_url
    if ethereum_contract_address
      site = ethereum_network? ? "#{ethereum_network}.etherscan.io" : Rails.application.config.ethereum_explorer_site
      site = 'etherscan.io' if site == 'main.etherscan.io'
      "https://#{site}/token/#{token.ethereum_contract_address}"
    elsif coin_type_on_qtum?
      UtilitiesService.get_contract_url(token.blockchain_network, token.contract_address)
    end
  end

  def currency_denomination
    Comakery::Currency::DENOMINATIONS[token.denomination]
  end

  def format_with_decimal_places(amount)
    if decimal_places.to_i.zero?
      number_with_precision(amount, precision: 0, delimiter: ',')
    else
      number_to_currency(amount, precision: decimal_places, unit: '')
    end
  end
end
