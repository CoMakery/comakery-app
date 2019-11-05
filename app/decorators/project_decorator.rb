class ProjectDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  PAYMENT_DESCRIPTIONS = {
    'project_token' => 'Project Tokens'
  }.freeze

  OUTSTANDING_AWARD_DESCRIPTIONS = {
    'project_token' => 'Project Tokens'
  }.freeze

  def description_html
    Comakery::Markdown.to_html(object.description)
  end

  def description_text(max_length = 90)
    Comakery::Markdown.to_text(object.description).truncate(max_length)
  end

  def ethereum_contract_explorer_url
    token&.decorate&.ethereum_contract_explorer_url
  end

  def status_description
    if project.license_finalized?
      'These terms are finalized and legally binding.'
    else
      'This is a draft of possible project terms that is not legally binding.'
    end
  end

  def currency_denomination
    token&.decorate&.currency_denomination
  end

  def payment_description
    PAYMENT_DESCRIPTIONS[project.payment_type]
  end

  def outstanding_award_description
    OUTSTANDING_AWARD_DESCRIPTIONS[project.payment_type]
  end

  def require_confidentiality_text
    project.require_confidentiality ? 'is required' : 'is not required'
  end

  def exclusive_contributions_text
    project.exclusive_contributions ? 'are exclusive' : 'are not exclusive'
  end

  def total_awards_outstanding_pretty
    # awards are validated as whole numbers; they are rounded
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
    if token && token.decimal_places.to_i.positive?
      number_to_currency(amount, precision: token.decimal_places, unit: '')
    else
      number_with_precision(amount, precision: 0, delimiter: ',')
    end
  end

  def maximum_tokens_pretty
    format_with_decimal_places(maximum_tokens)
  end

  def percent_awarded_pretty
    "#{number_with_precision(percent_awarded, precision: 3, delimiter: ',')}%"
  end

  def minimum_payment
    project_min_payment = Comakery::Currency::DEFAULT_MIN_PAYMENT[token.denomination]
    "#{currency_denomination}#{project_min_payment}"
  end

  def contributors_by_award_amount
    contributors_distinct.order_by_award(project)
  end

  def tokens_awarded_with_symbol
    token&.symbol ? "#{token.symbol} Tokens Awarded" : 'Tokens Awarded'
  end

  def send_coins?
    token&.coin_type? && %w[eth btc ada qtum eos xtz].include?(token&.coin_type)
  end

  def header_props
    {
      title: title,
      owner: legal_project_owner,
      image_url: helpers.attachment_url(self, :panoramic_image, :fill, 1500, 300, fallback: 'defaul_project.jpg'),
      settings_url: edit_project_path(self),
      admins_url: admins_project_path(self),
      batches_url: project_award_types_path(self),
      transfers_url: project_dashboard_transfers_path(self),
      accounts_url: project_dashboard_accounts_path(self),
      transfer_rules_url: project_dashboard_transfer_rules_path(self),
      landing_url: unlisted? ? unlisted_project_path(long_id) : project_path(self),
      show_batches: award_types.where.not(state: :draft).any?,
      show_transfers: !require_confidentiality?,
      supports_transfer_rules: supports_transfer_rules?,
      present: true
    }
  end

  def team_top
    (admins.includes(:specialty).first(4).to_a.unshift(account) + top_contributors.to_a + interested.includes(:specialty).first(5)).uniq
  end

  def team_size
    contributors_distinct.size + admins.size + interested.size + 1
  end

  def blockchain_name
    Token::BLOCKCHAIN_NAMES[token&.coin_type&.to_sym]
  end

  def step_for_amount_input
    token ? (1.0 / 10**token.decimal_places) : 1
  end

  def step_for_quantity_input
    token ? 0.1 : 1
  end

  private

  def self.pretty_number(*currency_methods)
    currency_methods.each do |method_name|
      define_method "#{method_name}_pretty" do
        number_with_precision(send(method_name), precision: 0, delimiter: ',').to_s
      end
    end
  end

  pretty_number :maximum_tokens
end
