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

  def bitcoin_wallet_url
    UtilitiesService.get_wallet_url('bitcoin_mainnet', bitcoin_wallet)
  end

  def cardano_wallet_url
    UtilitiesService.get_wallet_url('cardano_mainnet', cardano_wallet)
  end

  def eos_wallet_url
    UtilitiesService.get_wallet_url('eos_mainnet', eos_wallet)
  end

  def tezos_wallet_url
    UtilitiesService.get_wallet_url('tezos_mainnet', tezos_wallet)
  end

  def ethereum_wallet_url
    "https://etherscan.io/address/#{ethereum_wallet}"
  end

  def etherscan_address
    "https://etherscan.io/address/#{ethereum_wallet}"
  end

  def qtum_wallet_url
    UtilitiesService.get_wallet_url('qtum_mainnet', qtum_wallet)
  end

  def wallet_address_link_for(project)
    project = project.decorate
    address = project.blockchain_name.present? && send("#{project.blockchain_name}_wallet")

    if address.present?
      h.link_to(address, send("#{project.blockchain_name}_wallet_url"), target: '_blank')
    else
      'needs wallet'
    end
  end

  def can_receive_awards?(project)
    return false unless project.token&.coin_type?
    blockchain_name = Token::BLOCKCHAIN_NAMES[project.token.coin_type.to_sym]
    account&.send("#{blockchain_name}_wallet?")
  end

  def can_send_awards?(project)
    (project&.account == self || project.admins.include?(self)) && (project&.token&.ethereum_contract_address? || project&.token&.contract_address? || project.decorate.send_coins?)
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
end
