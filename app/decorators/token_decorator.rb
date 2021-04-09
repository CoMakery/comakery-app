class TokenDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def currency_denomination
    Comakery::Currency::DENOMINATIONS[token.denomination]
  end

  def eth_data(controller_name = 'ethereum')
    case _token_type
    when 'erc20', 'eth', 'comakery_security_token'
      {
        "#{controller_name}-payment-type" => _token_type,
        "#{controller_name}-amount" => 0,
        "#{controller_name}-decimal-places" => decimal_places&.to_i,
        "#{controller_name}-contract-address" => contract_address,
        "#{controller_name}-contract-abi" => abi&.to_json
      }
    end
  end

  def network
    _blockchain
  end

  def logo_url(host: Rails.application.routes.default_url_options[:host])
    Rails.application.routes.url_helpers.polymorphic_url(logo_image, host: host) if logo_image
  end
end
