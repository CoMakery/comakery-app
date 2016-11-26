class ProjectDecorator < Draper::Decorator
  delegate_all

  PAYMENT_DESCRIPTIONS = { "royalty_usd" => "Royalties",
                     "royalty_btc" => "Royalties",
                     "royalty_eth" => "Royalties",
                     "project_coin" => "Project Coins",
  }

  CURRENCY_DENOMINATIONS = {
      "royalty_usd" => "$",
      "royalty_btc" => "฿",
      "royalty_eth" => "Ξ",
      "project_coin" => ""
  }

  def description_html
    Comakery::Markdown.to_html(object.description)
  end

  def description_text(max_length = 90)
    Comakery::Markdown.to_text(object.description).truncate(max_length)
  end

  def ethereum_contract_explorer_url
    if ethereum_contract_address
      "https://#{Rails.application.config.ethercamp_subdomain}.ether.camp/account/#{project.ethereum_contract_address}"
    else
      nil
    end
  end

  def currency_denomination
    CURRENCY_DENOMINATIONS[project.payment_type]
  end

  def payment_description
    PAYMENT_DESCRIPTIONS[project.payment_type]
  end
end
