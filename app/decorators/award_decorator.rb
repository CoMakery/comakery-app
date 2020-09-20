class AwardDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def ethereum_transaction_address
    object.ethereum_transaction_address || object.latest_blockchain_transaction&.tx_hash
  end

  def ethereum_transaction_address_short
    "#{ethereum_transaction_address[0...10]}..." if ethereum_transaction_address
  end

  def ethereum_transaction_explorer_url
    token.blockchain.url_for_tx_human(ethereum_transaction_address) if ethereum_transaction_address.present?
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
          only: %i[id contract_address _blockchain blockchain_network _token_type]
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

  def issuer_address # rubocop:todo Metrics/CyclomaticComplexity
    if object.token&._token_type_on_ethereum?
      issuer&.ethereum_wallet
    elsif object.token&._token_type_on_qtum?
      issuer&.qtum_wallet
    elsif object.token&._token_type_ada?
      issuer&.cardano_wallet
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

  def stimulus_data(controller_name, action) # rubocop:todo Metrics/CyclomaticComplexity
    case project.token&._token_type
    when 'erc20', 'eth', 'comakery_security_token'
      {
        'controller' => controller_name,
        'target' => "#{controller_name}.button",
        'action' => "click->#{controller_name}##{action}",
        "#{controller_name}-id" => id,
        "#{controller_name}-payment-type" => project.token&._token_type,
        "#{controller_name}-address" => account.ethereum_wallet,
        "#{controller_name}-amount" => total_amount_wei,
        "#{controller_name}-decimal-places" => project.token&.decimal_places&.to_i,
        "#{controller_name}-contract-address" => project.token&.contract_address,
        "#{controller_name}-contract-abi" => project.token&.abi&.to_json,
        "#{controller_name}-transactions-path" => api_v1_project_blockchain_transactions_path(project_id: project.id),
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
    case transfer_type.name
    when 'mint'
      'Mint'
    when 'burn'
      'Burn'
    else
      'Pay'
    end
  end

  def pay_data
    case transfer_type.name
    when 'mint'
      stimulus_data('ethereum', 'mint')
    when 'burn'
      stimulus_data('ethereum', 'burn')
    else
      stimulus_data('ethereum', 'pay')
    end
  end

  def transfer_button_state_class # rubocop:todo Metrics/CyclomaticComplexity
    case latest_blockchain_transaction&.status
    when 'created'
      'in-progress--metamask' if latest_blockchain_transaction&.waiting_in_created?
    when 'pending'
      'in-progress--metamask in-progress--metamask__paid'
    end
  end
end
