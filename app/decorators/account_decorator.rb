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

  def etherscan_address
    "https://etherscan.io/address/#{ethereum_wallet}"
  end

  def qtum_wallet_url
    UtilitiesService.get_wallet_url('qtum_mainnet', qtum_wallet)
  end

  def can_receive_awards?(project)
    if project.coin_type_on_ethereum?
      ethereum_wallet?
    elsif project.coin_type_on_qtum?
      qtum_wallet?
    elsif project.coin_type_on_cardano?
      cardano_wallet?
    elsif project.coin_type_on_bitcoin?
      bitcoin_wallet?
    else
      false
    end
  end

  def can_send_awards?(project)
    project&.account == self && (project&.ethereum_contract_address? || project&.contract_address? || project.decorate.send_coins?)
  end

  def total_awards_earned_pretty(project)
    pretty_award total_awards_earned(project)
  end

  def total_awards_remaining_pretty(project)
    pretty_award total_awards_remaining(project)
  end

  def total_revenue_unpaid_remaining_pretty(project)
    pretty_currency(project, total_revenue_unpaid(project))
  end

  def total_revenue_paid_pretty(project)
    pretty_currency(project, total_revenue_paid(project))
  end

  def percentage_of_unpaid_pretty(project)
    "#{number_with_precision(percent_unpaid(project).truncate(1), precision: 1)}%"
  end

  private

  def pretty_currency(project, amount_to_make_pretty)
    precision = Comakery::Currency::PRECISION[project.denomination]
    denomination = Comakery::Currency::DENOMINATIONS[project.denomination]
    "#{denomination}#{number_with_precision(amount_to_make_pretty.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def pretty_award(award_amount_to_make_pretty)
    number_with_precision(award_amount_to_make_pretty, precision: 0, delimiter: ',')
  end
end
