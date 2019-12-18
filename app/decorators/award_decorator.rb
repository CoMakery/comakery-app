class AwardDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

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

  def total_amount_wei
    BigDecimal(10.pow(project.token&.decimal_places || 0) * total_amount)&.to_s&.to_i
  end

  def stimulus_data(controller_name, action)
    case project.token&.coin_type
    when 'erc20', 'eth', 'comakery'
      {
        'controller' => controller_name,
        'target' => "#{controller_name}.button",
        'action' => "click->#{controller_name}##{action}",
        "#{controller_name}-payment-type" => project.token&.coin_type,
        "#{controller_name}-address" => account.ethereum_wallet,
        "#{controller_name}-amount" => total_amount_wei,
        "#{controller_name}-contract-address" => project.token&.ethereum_contract_address,
        "#{controller_name}-contract-abi" => project.token&.abi&.to_json,
        "#{controller_name}-update-transaction-path" => project_award_type_award_update_transaction_address_path(project, award_type, self),
        'info' => json_for_sending_awards
      }
    else
      {
        id: id,
        info: json_for_sending_awards
      }
    end
  end

  def transfer_button_text
    case source
    when 'mint'
      'Mint'
    when 'burn'
      'Burn'
    else
      'Pay'
    end
  end

  def pay_data
    case source
    when 'mint'
      stimulus_data('comakery-security-token', 'mint')
    when 'burn'
      stimulus_data('comakery-security-token', 'burn')
    else
      stimulus_data('ethereum', 'pay')
    end
  end
end
