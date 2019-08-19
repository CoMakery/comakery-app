class AccountDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def name
    return nickname if nickname.present?
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def nick
    nickname || name
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

  def etherscan_address
    "https://etherscan.io/address/#{ethereum_wallet}"
  end

  def qtum_wallet_url
    UtilitiesService.get_wallet_url('qtum_mainnet', qtum_wallet)
  end

  def can_receive_awards?(project)
    return false unless project.token&.coin_type?
    blockchain_name = Token::BLOCKCHAIN_NAMES[project.token.coin_type.to_sym]
    account&.send("#{blockchain_name}_wallet?")
  end

  def can_send_awards?(project)
    project&.account == self && (project&.token&.ethereum_contract_address? || project&.token&.contract_address? || project.decorate.send_coins?)
  end

  def image_url(size = 100)
    if image
      Refile.attachment_url(self, :image, :fill, size, size)
    else
      ActionController::Base.helpers.image_url('default_account_image.jpg')
    end
  end
end
