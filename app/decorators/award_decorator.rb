class AwardDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def ethereum_transaction_address_short
    if object.ethereum_transaction_address
      "#{object.ethereum_transaction_address[0...10]}..."
    end
  end

  def ethereum_transaction_explorer_url
    if object.ethereum_transaction_address
      site = object.project&.ethereum_network? ? "#{object.project.ethereum_network}.etherscan.io" : Rails.application.config.ethereum_explorer_site
      site = 'etherscan.io' if site == 'main.etherscan.io'
      "https://#{site}/tx/#{object.ethereum_transaction_address}"
    end
  end

  def json_for_sending_awards
    to_json(only: %i[id total_amount], methods: %i[issuer_address amount_to_send], include: { account: { only: %i[id ethereum_wallet] }, project: { only: %i[id ethereum_contract_address] } })
  end

  def unit_amount_pretty
    number_with_delimiter(unit_amount)
  end

  def total_amount_pretty
    if project.decimal_places.to_i == 0
      number_with_delimiter(total_amount.to_i)
    else
      number_to_currency(BigDecimal(amount_to_send) / project.decimal_places_value, precision: project.decimal_places, unit: '')
    end
  end

  def part_of_email
    "#{email.split('@').first}@..." if email
  end

  def recipient_display_name
    account ? account.decorate.name : part_of_email
  end

  def recipient_user_name
    recipient_auth_team&.name || account.decorate.name
  end

  def recipient_address
    account&.ethereum_wallet
  end

  def issuer_address
    issuer&.ethereum_wallet
  end

  def issuer_display_name
    issuer&.decorate&.name
  end

  def issuer_user_name
    team&.authentication_team_by_account(issuer)&.name || issuer.decorate.name
  end

  def communication_channel
    if channel
      channel.name_with_provider
    else
      'Email'
    end
  end
end
