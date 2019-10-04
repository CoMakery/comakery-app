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
      if (network = object.token&.blockchain_network).present?
        UtilitiesService.get_transaction_url(network, object.ethereum_transaction_address)
      else
        site = object.token&.ethereum_network? ? "#{object.token&.ethereum_network}.etherscan.io" : Rails.application.config.ethereum_explorer_site
        site = 'etherscan.io' if site == 'main.etherscan.io'
        "https://#{site}/tx/#{object.ethereum_transaction_address}"
      end
    end
  end

  def json_for_sending_awards
    to_json(
      only: %i[id total_amount],
      methods: %i[issuer_address amount_to_send recipient_display_name],
      include: {
        account: {
          only: %i[id ethereum_wallet qtum_wallet cardano_wallet qtum_wallet bitcoin_wallet eos_wallet tezos_wallet]
        },
        project: {
          only: %i[id]
        },
        award_type: {
          only: %i[id]
        },
        token: {
          only: %i[id contract_address ethereum_contract_address coin_type ethereum_network blockchain_network]
        }
      }
    )
  end

  def amount_pretty
    number_with_precision(amount, precision: token&.decimal_places.to_i)
  end

  def total_amount_pretty
    number_to_currency(total_amount, precision: token&.decimal_places.to_i, unit: '')
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
    blockchain_name = Token::BLOCKCHAIN_NAMES[token.coin_type.to_sym]
    blockchain_name ? account&.send("#{blockchain_name}_wallet") : nil
  end

  def issuer_address
    if object.token&.coin_type_on_ethereum?
      issuer&.ethereum_wallet
    elsif object.token&.coin_type_on_qtum?
      issuer&.qtum_wallet
    elsif object.token&.coin_type_ada?
      issuer&.cardano_wallet
    end
  end

  def issuer_address_url
    if object.token&.coin_type_on_ethereum?
      issuer&.decorate&.etherscan_address
    elsif object.token&.coin_type_on_qtum?
      issuer&.decorate&.qtum_wallet_url
    elsif object.token&.coin_type_ada?
      issuer&.decorate&.cardano_wallet_url
    end
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
