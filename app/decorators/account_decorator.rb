class AccountDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def nick
    nickname || name
  end

  def name_with_nickname
    if nickname.present?
      "#{name} (#{nickname})"
    else
      name
    end
  end

  def bitcoin_wallet_url(network = 'bitcoin')
    Token.blockchain_for(network.capitalize).url_for_address_human(bitcoin_wallet)
  end

  def cardano_wallet_url(network = 'cardano')
    Token.blockchain_for(network.capitalize).url_for_address_human(cardano_wallet)
  end

  def eos_wallet_url(network = 'eos')
    Token.blockchain_for(network.capitalize).url_for_address_human(eos_wallet)
  end

  def tezos_wallet_url(network = 'tezos')
    Token.blockchain_for(network.capitalize).url_for_address_human(tezos_wallet)
  end

  def ethereum_wallet_url(network = 'ethereum')
    Token.blockchain_for(network.capitalize).url_for_address_human(ethereum_wallet)
  end

  def etherscan_address(network = 'ethereum')
    Token.blockchain_for(network.capitalize).url_for_address_human(ethereum_wallet)
  end

  def qtum_wallet_url(network = 'qtum')
    Token.blockchain_for(network.capitalize).url_for_address_human(qtum_wallet)
  end

  def wallet_address_for(project)
    blockchain_name = project.decorate.blockchain_name
    blockchain_name && send("#{blockchain_name}_wallet")
  end

  def wallet_address_url_for(project) # rubocop:todo Metrics/CyclomaticComplexity
    address = wallet_address_for(project)
    blockchain = project.token&.blockchain

    if address.present? && blockchain.present?
      blockchain.url_for_address_human(address)
    end
  end

  def wallet_address_link_for(project)
    address = wallet_address_for(project)
    url = wallet_address_url_for(project)

    if url
      h.link_to(address, url, target: '_blank', rel: 'noopener')
    else
      'needs wallet'
    end
  end

  def can_receive_awards?(project)
    return false unless project.token&._token_type?
    account&.send("#{project.token&.blockchain_name_for_wallet}_wallet?")
  end

  def can_send_awards?(project)
    (project&.account == self || project.admins.include?(self)) && (project&.token&.contract_address? || project.decorate.send_coins?)
  end

  def image_url(size = 100)
    helpers.attachment_url(self, :image, :fill, size, size, fallback: 'default_account_image.jpg')
  end

  def verification_state
    case latest_verification&.passed?
    when true
      'passed'
    when false
      'failed'
    else
      'unknown'
    end
  end

  def verification_date
    latest_verification&.created_at
  end

  def verification_max_investment_usd
    latest_verification&.max_investment_usd
  end

  def total_received_in(token)
    awards.paid.joins(:project).where('projects.token_id = :id', id: token.id).sum(:total_amount)
  end

  def total_accepted_in(token)
    awards.accepted.joins(:project).where('projects.token_id = :id', id: token.id).sum(:total_amount)
  end

  def total_received_and_accepted_in(token)
    total_received_in(token) + total_accepted_in(token)
  end
end
