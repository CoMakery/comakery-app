class AwardDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def ethereum_transaction_address
    token && (object.ethereum_transaction_address || object.latest_blockchain_transaction&.tx_hash)
  end

  def ethereum_transaction_address_short
    "#{ethereum_transaction_address[0...10]}..." if ethereum_transaction_address
  end

  def ethereum_transaction_explorer_url
    token.blockchain.url_for_tx_human(ethereum_transaction_address) if ethereum_transaction_address.present?
  end

  def amount_pretty
    number_with_precision(amount, precision: token&.decimal_places.to_i)
  end

  def total_amount_pretty
    number_to_currency(total_amount, precision: token&.decimal_places.to_i, unit: '')
  end

  def transfer_transaction # rubocop:todo Metrics/CyclomaticComplexity
    if project.token&._token_type?
      if paid? && object.ethereum_transaction_address
        ethereum_transaction_address
      elsif project.token.token_frozen?
        'frozen'
      elsif recipient_address.blank?
        'needs wallet'
      else
        'pending'
      end
    else
      '-'
    end
  end

  def transfer_type_name
    transfer_type ? transfer_type.name : '-'
  end

  def transfered_date
    paid? && transferred_at ? transferred_at.strftime('%b %e %Y') : '–'
  end

  def created_date
    created_at.strftime('%b %e %Y')
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
    account ? account.address_for_blockchain(object.token&._blockchain) : ''
  end

  def issuer_address
    issuer.address_for_blockchain(object.token&._blockchain)
  end

  def issuer_first_name
    issuer&.decorate&.first_name
  end

  def issuer_last_name
    issuer&.decorate&.last_name
  end

  def recipient_first_name
    account ? account.decorate.first_name : part_of_email
  end

  def recipient_last_name
    account ? account.decorate.last_name : '-'
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

  def transfer_button_state_class
    case latest_blockchain_transaction&.status
    when 'created'
      'in-progress--metamask' if latest_blockchain_transaction&.waiting_in_created?
    when 'pending'
      'in-progress--metamask in-progress--metamask__paid'
    end
  end
end
