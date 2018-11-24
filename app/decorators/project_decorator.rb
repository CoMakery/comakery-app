class ProjectDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  PAYMENT_DESCRIPTIONS = {
    'revenue_share' => 'Revenue Shares',
    'project_token' => 'Project Tokens'
  }.freeze

  OUTSTANDING_AWARD_DESCRIPTIONS = {
    'revenue_share' => 'Unpaid Revenue Shares',
    'project_token' => 'Project Tokens'
  }.freeze

  def description_html
    Comakery::Markdown.to_html(object.description)
  end

  def description_text(max_length = 90)
    Comakery::Markdown.to_text(object.description).truncate(max_length)
  end

  def ethereum_contract_explorer_url
    if ethereum_contract_address
      site = ethereum_network? ? "#{ethereum_network}.etherscan.io" : Rails.application.config.ethereum_explorer_site
      site = 'etherscan.io' if site == 'main.etherscan.io'
      "https://#{site}/token/#{project.ethereum_contract_address}"
    elsif coin_type_on_qtum?
      UtilitiesService.get_contract_url(project.blockchain_network, project.contract_address)
    end
  end

  def status_description
    if project.license_finalized?
      'These terms are finalized and legally binding.'
    else
      'This is a draft of possible project terms that is not legally binding.'
    end
  end

  def currency_denomination
    Comakery::Currency::DENOMINATIONS[project.denomination]
  end

  def payment_description
    PAYMENT_DESCRIPTIONS[project.payment_type]
  end

  def outstanding_award_description
    OUTSTANDING_AWARD_DESCRIPTIONS[project.payment_type]
  end

  def royalty_percentage_pretty
    return '0%' if project.royalty_percentage.blank?
    "#{number_with_precision(project.royalty_percentage,
      precision: Project::ROYALTY_PERCENTAGE_PRECISION,
      strip_insignificant_zeros: true)}%"
  end

  def require_confidentiality_text
    project.require_confidentiality ? 'is required' : 'is not required'
  end

  def exclusive_contributions_text
    project.exclusive_contributions ? 'are exclusive' : 'are not exclusive'
  end

  def total_revenue_pretty
    precision = Comakery::Currency::PRECISION[denomination]
    "#{currency_denomination}#{number_with_precision(total_revenue.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def total_revenue_shared_pretty
    precision = Comakery::Currency::PRECISION[denomination]
    "#{currency_denomination}#{number_with_precision(total_revenue_shared.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def total_awards_outstanding_pretty
    # awards (e.g. project tokens or revenue shares) are validated as whole numbers; they are rounded
    number_with_precision(total_awards_outstanding, precision: 0, delimiter: ',')
  end

  def total_awarded_pretty
    format_with_decimal_places(total_awarded)
  end

  def total_awarded_to_user(account)
    amount = account.total_awards_earned(self)
    format_with_decimal_places(amount)
  end

  def format_with_decimal_places(amount)
    if decimal_places.to_i.zero?
      number_with_precision(amount, precision: 0, delimiter: ',')
    else
      number_to_currency(amount, precision: decimal_places, unit: '')
    end
  end

  def maximum_tokens_pretty
    number_with_precision(maximum_tokens, precision: 0, delimiter: ',')
  end

  def total_awards_redeemed_pretty
    number_with_precision(total_awards_redeemed, precision: 0, delimiter: ',')
  end

  def percent_awarded_pretty
    "#{number_with_precision(percent_awarded, precision: 3, delimiter: ',')}%"
  end

  def revenue_per_share_pretty
    precision = Comakery::Currency::PER_SHARE_PRECISION[denomination]
    "#{currency_denomination}#{number_with_precision(revenue_per_share.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def total_revenue_shared_unpaid_pretty
    precision = Comakery::Currency::ROUNDED_BALANCE_PRECISION[denomination]
    "#{currency_denomination}#{number_with_precision(total_revenue_shared_unpaid.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def total_paid_to_contributors_pretty
    precision = Comakery::Currency::ROUNDED_BALANCE_PRECISION[denomination]
    "#{currency_denomination}#{number_with_precision(total_paid_to_contributors.truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def minimum_revenue
    "#{currency_denomination}0"
  end

  def minimum_payment
    project_min_payment = Comakery::Currency::DEFAULT_MIN_PAYMENT[denomination]
    "#{currency_denomination}#{project_min_payment}"
  end

  def revenue_history
    project.revenues.order(created_at: :desc, id: :desc).decorate
  end

  def payment_history
    project.payments.order(created_at: :desc, id: :desc)
  end

  def share_of_revenue_unpaid_pretty(users_project_tokens)
    precision = Comakery::Currency::ROUNDED_BALANCE_PRECISION[denomination]
    "#{currency_denomination}#{number_with_precision(share_of_revenue_unpaid(users_project_tokens).truncate(precision),
      precision: precision,
      delimiter: ',')}"
  end

  def revenue_sharing_end_date_pretty
    return 'revenue sharing does not have an end date.' if project.revenue_sharing_end_date.blank?
    project.revenue_sharing_end_date.strftime('%B %-d, %Y')
  end

  def contributors_by_award_amount
    contributors_distinct.order_by_award(project)
  end

  def tokens_awarded_with_symbol
    token_symbol ? "#{token_symbol} Tokens Awarded" : 'Tokens Awarded'
  end

  private

  def self.pretty_number(*currency_methods)
    currency_methods.each do |method_name|
      define_method "#{method_name}_pretty" do
        number_with_precision(send(method_name), precision: 0, delimiter: ',').to_s
      end
    end
  end

  pretty_number :maximum_royalties_per_month, :maximum_tokens
end
