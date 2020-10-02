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

  def wallet_address_for(project)
    address_for_blockchain(project.token&._blockchain)
  end

  def wallet_address_url_for(project)
    address = wallet_address_for(project)
    blockchain = project.token&.blockchain

    blockchain.url_for_address_human(address) if address.present? && blockchain.present?
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
    project.token._blockchain && account.address_for_blockchain(project.token._blockchain).present?
  end

  def can_send_awards?(project)
    project&.account == self || project.admins.include?(self)
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
