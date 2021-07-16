class AwardDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def sender_wallet_address
    return unless paid?

    blockchain_transactions.succeed.last&.source
  end

  def recipient_wallet_address
    return unless recipient_wallet

    recipient_wallet.address
  end

  def sender_wallet_url
    return if sender_wallet_address.blank?

    token&.blockchain&.url_for_address_human(sender_wallet_address)
  end

  def recipient_wallet_url
    return if recipient_wallet_address.blank?

    token&.blockchain&.url_for_address_human(recipient_wallet_address)
  end

  def ethereum_transaction_address
    token && (object.ethereum_transaction_address || object.latest_blockchain_transaction&.tx_hash)
  end

  def ethereum_transaction_address_short
    "#{ethereum_transaction_address[0...10]}..." if ethereum_transaction_address.present?
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

  def to_csv_header
    [
      'Id',
      'Transfer Type',
      'Recipient Id',
      'Recipient First Name',
      'Recipient Last Name',
      'Recipient Email',
      'Recipient Blockchain Address',
      'Recipient Verification',
      'Sender Id',
      'Sender First Name',
      'Sender Last Name',
      'Sender Blockchain Address',
      "Total Amount #{token&.symbol}",
      'Transaction Hash',
      'Transaction Blockchain',
      'Transfer Status',
      'Transferred At',
      'Created At'
    ]
  end

  # rubocop:todo Metrics/CyclomaticComplexity
  # rubocop:todo Metrics/PerceivedComplexity
  def to_csv
    [
      id,
      transfer_type&.name,
      account&.managed_account_id || account&.id,
      account&.first_name,
      account&.last_name,
      account&.email || email,
      recipient_wallet&.address,
      account&.decorate&.verification_state,
      issuer.managed_account_id || issuer.id,
      issuer.first_name,
      issuer.last_name,
      latest_blockchain_transaction&.source,
      total_amount,
      paid? ? ethereum_transaction_address : nil,
      token&.blockchain&.name,
      status,
      transferred_at,
      created_at
    ]
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
    issuer.address_for_blockchain(object.token&._blockchain)
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

  def show_prioritize_button?
    return false if project.hot_wallet_disabled?
    return true if latest_blockchain_transaction.nil?
    return project.hot_wallet_manual_sending? if latest_blockchain_transaction.failed?

    latest_blockchain_transaction.status.in?(%w[created cancelled])
  end
end
