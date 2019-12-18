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

  def eth_data(controller_name = 'ethereum')
    case coin_type
    when 'erc20', 'eth', 'comakery'
      {
        "#{controller_name}-payment-type" => coin_type,
        "#{controller_name}-amount" => 0,
        "#{controller_name}-contract-address" => ethereum_contract_address,
        "#{controller_name}-contract-abi" => abi&.to_json
      }
    end
  end
end
