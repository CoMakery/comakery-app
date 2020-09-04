class TokenDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def currency_denomination
    Comakery::Currency::DENOMINATIONS[token.denomination]
  end

  def eth_data(controller_name = 'ethereum')
    case coin_type
    when 'erc20', 'eth', 'comakery'
      {
        "#{controller_name}-payment-type" => coin_type,
        "#{controller_name}-amount" => 0,
        "#{controller_name}-decimal-places" => decimal_places&.to_i,
        "#{controller_name}-contract-address" => contract_address,
        "#{controller_name}-contract-abi" => abi&.to_json
      }
    end
  end

  def network
    blockchain_network
  end

  def logo_url(size = 100)
    helpers.attachment_url(self, :logo_image, :fill, size, size, fallback: 'defaul_project.jpg')
  end
end
