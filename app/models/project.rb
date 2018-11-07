class Project < ApplicationRecord
  ROYALTY_PERCENTAGE_PRECISION = 13

  include EthereumAddressable
  include QtumContractAddressable

  nilify_blanks
  attachment :image

  belongs_to :account
  has_many :award_types, inverse_of: :project, dependent: :destroy
  has_many :awards, through: :award_types, dependent: :destroy
  has_many :completed_awards, -> { where.not ethereum_transaction_address: nil }, through: :award_types, source: :awards
  has_many :channels, -> { order :created_at }, inverse_of: :project, dependent: :destroy
  has_many :payments, dependent: :destroy do
    def new_with_quantity(quantity_redeemed:, account:)
      project = @association.owner
      quantity = quantity_redeemed.blank? ? 0 : quantity_redeemed
      new(total_value: BigDecimal(quantity) * project.revenue_per_share,
          quantity_redeemed: quantity_redeemed,
          share_value: project.revenue_per_share,
          currency: project.denomination,
          account: account)
        .tap(&:truncate_total_value_to_currency_precision)
    end

    def create_with_quantity(**attrs)
      new_with_quantity(**attrs).tap(&:save)
    end
  end

  has_many :contributors, through: :awards, source: :account # TODO: deprecate in favor of contributors_distinct
  has_many :contributors_distinct, -> { distinct }, through: :awards, source: :account
  has_many :revenues
  has_many :teams, through: :account

  accepts_nested_attributes_for :award_types, reject_if: :invalid_params, allow_destroy: true
  accepts_nested_attributes_for :channels, reject_if: :invalid_channel, allow_destroy: true

  enum payment_type: {
    revenue_share: 0,
    project_token: 1
  }
  enum coin_type: {
    erc20: 'ERC20',
    eth: 'ETH',
    qrc20: 'QRC20',
    qtum: 'QTUM'
  }, _prefix: :coin_type

  enum denomination: {
    USD: 0,
    BTC: 1,
    ETH: 2
  }
  enum visibility: %i[member public_listed member_unlisted public_unlisted archived]
  enum ethereum_network: {
    main:    'Main Ethereum Network',
    ropsten: 'Ropsten Test Network',
    kovan:   'Kovan Test Network',
    rinkeby: 'Rinkeby Test Network'
  }
  enum blockchain_network: {
    qtum_mainnet: 'Main QTUM Network',
    qtum_testnet: 'Test QTUM Network'
  }

  validates :description, :account, :title, :legal_project_owner,
    :denomination, presence: true

  validates :royalty_percentage, :maximum_royalties_per_month, presence: { if: :revenue_share? }

  validates :maximum_tokens, numericality: { greater_than: 0 }
  validates :royalty_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }

  validate :valid_tracker_url, if: -> { tracker.present? }
  validate :valid_contributor_agreement_url, if: -> { contributor_agreement_url.present? }
  validate :valid_video_url, if: -> { video_url.present? }

  validate :maximum_tokens_unchanged, if: -> { !new_record? }
  validate :valid_ethereum_enabled
  validate :check_contract_address_exist_on_blockchain_network
  validates :contract_address, qtum_contract_address: true # see QtumContractAddressable
  validates :ethereum_contract_address, ethereum_address: { type: :account } # see EthereumAddressable
  validate :denomination_changeable
  validate :contract_address_changeable, if: -> { completed_awards.present? }

  before_validation :populate_token_symbol
  before_validation :check_coin_type
  before_save :set_transitioned_to_ethereum_enabled
  before_save :enable_ethereum

  scope :featured, -> { order :featured }
  scope :unlisted, -> { where 'projects.visibility in(2,3)' }
  scope :listed, -> { where 'projects.visibility not in(2,3)' }
  scope :visible, -> { where 'projects.visibility not in(2,3,4)' }
  scope :unarchived, -> { where.not visibility: 4 }
  scope :publics, -> { where 'projects.visibility in(1,3)' }
  def self.with_last_activity_at
    select(Project.column_names.map { |c| "projects.#{c}" }.<<('max(awards.created_at) as last_award_created_at').join(','))
      .joins('left join award_types on projects.id = award_types.project_id')
      .joins('left join awards on award_types.id = awards.award_type_id')
      .group('projects.id')
      .order('max(awards.created_at) desc nulls last, projects.created_at desc nulls last')
  end

  def top_contributors
    Account.select('accounts.*, sum(a1.total_amount) as total_awarded, max(a1.created_at) as last_awarded_at').joins("
      left join awards a1 on a1.account_id=accounts.id
      left join award_types on a1.award_type_id=award_types.id
      left join projects on award_types.project_id=projects.id")
           .where('projects.id=?', id)
           .group('accounts.id')
           .order('total_awarded desc, last_awarded_at desc').first(5)
  end

  def create_ethereum_awards!
    CreateEthereumAwards.call(awards: awards)
  end

  def coin_type_token?
    coin_type_erc20? || coin_type_qrc20?
  end

  def coin_type_on_ethereum?
    coin_type_erc20? || coin_type_eth?
  end

  def coin_type_on_qtum?
    coin_type_qrc20? || coin_type_qtum?
  end

  def total_revenue
    revenues.total_amount
  end

  def total_month_awarded
    awards.where('awards.created_at >= ?', Time.zone.today.beginning_of_month).sum(:total_amount)
  end

  delegate :total_awarded, to: :awards

  def total_awards_outstanding
    total_awarded - total_awards_redeemed
  end

  def total_awards_redeemed
    payments.sum(:quantity_redeemed)
  end

  def share_of_revenue_unpaid(awards)
    return BigDecimal(0) if royalty_percentage.blank? || total_revenue_shared == 0 || total_awarded == 0 || awards.blank?
    (BigDecimal(awards) * revenue_per_share).truncate(currency_precision)
  end

  def total_revenue_shared
    return BigDecimal(0) if royalty_percentage.blank? || project_token?
    total_revenue * (royalty_percentage * BigDecimal('0.01'))
  end

  def total_paid_to_contributors
    payments.sum(:total_value)
  end

  def total_revenue_shared_unpaid
    total_revenue_shared - total_paid_to_contributors
  end

  # truncated to 8 decimal places
  def revenue_per_share
    return BigDecimal(0) if royalty_percentage.blank? || total_awarded == 0
    (total_revenue_shared_unpaid / BigDecimal(total_awards_outstanding)).truncate(8)
  end

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_params(attributes)
    AwardType.invalid_params(attributes)
  end

  def invalid_channel(attributes)
    Channel.invalid_params(attributes)
  end

  # def owner_slack_user_name
  #   account.authentications.find_by(slack_team_id: slack_team_id)&.display_name
  # end

  def youtube_id
    # taken from http://stackoverflow.com/questions/5909121/converting-a-regular-youtube-link-into-an-embedded-video
    # Regex from http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
    if video_url[/youtu\.be\/([^\?]*)/]
      youtube_id = Regexp.last_match(1)
    else
      video_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = Regexp.last_match(5)
    end
    youtube_id
  end

  def transitioned_to_ethereum_enabled?
    !!@transitioned_to_ethereum_enabled
  end

  def share_revenue?
    revenue_share? && (royalty_percentage&.> 0)
  end

  def show_id
    unlisted? ? long_id : id
  end

  def public?
    public_listed? || public_unlisted?
  end

  def access_unlisted?(check_account)
    return true if public_unlisted?
    return true if member_unlisted? && check_account&.same_team_or_owned_project?(self)
  end

  def can_be_access?(check_account)
    return true if public? && !require_confidentiality?
    check_account && check_account.same_team_or_owned_project?(self)
  end

  def show_revenue_info?(account)
    share_revenue? && can_be_access?(account)
  end

  def unlisted?
    member_unlisted? || public_unlisted?
  end

  def royalty_percentage=(x)
    x_truncated = BigDecimal(x, ROYALTY_PERCENTAGE_PRECISION).truncate(ROYALTY_PERCENTAGE_PRECISION) if x.present?
    self[:royalty_percentage] = x_truncated
  end

  def percent_awarded
    total_awarded * 100.0 / maximum_tokens
  end

  def decimal_places_value
    10**decimal_places.to_i
  end

  def awards_for_chart
    result = []
    recents = awards.where('awards.created_at > ?', 150.days.ago).order(:created_at)
    date_groups = recents.group_by { |a| a.created_at.strftime('%Y-%m-%d') }
    contributors = {}
    recents.map(&:account).uniq.each do |a|
      name = a&.decorate&.name || 'Others'
      contributors[name] = 0
    end
    date_groups.each do |group|
      item = {}
      item[:date] = group[0]
      item = item.merge(contributors)
      user_groups = group[1].group_by(&:account)
      user_groups.each do |ugroup|
        name = ugroup[0]&.decorate&.name || 'Others'
        item[name] = ugroup[1].sum(&:total_amount)
      end
      result << item
    end
    result
  end

  def populate_token?
    ethereum_contract_address.present? && project_token? && (token_symbol.blank? || decimal_places.blank?)
  end

  private

  def check_coin_type
    check_coin_type_blockchain_network
    if coin_type_erc20?
      self.contract_address = nil
    elsif coin_type_qrc20?
      self.ethereum_contract_address = nil
    elsif coin_type?
      self.contract_address = nil
      self.ethereum_contract_address = nil
      self.token_symbol   = nil
      self.decimal_places = nil
    end
  end

  def check_coin_type_blockchain_network
    if coin_type_on_ethereum?
      self.blockchain_network = nil
    elsif coin_type_on_qtum?
      self.ethereum_network = nil
    end
  end

  def populate_token_symbol
    if populate_token?
      symbol, decimals = Comakery::Ethereum.token_symbol(ethereum_contract_address, self)
      self.token_symbol = symbol if token_symbol.blank?
      self.decimal_places = decimals if decimal_places.blank?
      ethereum_contract_address_exist_on_network?(symbol)
    end
  end

  def enable_ethereum
    self.ethereum_enabled = ethereum_contract_address.present? || contract_address? unless ethereum_enabled
  end

  def valid_tracker_url
    validate_url(:tracker)
  end

  def valid_contributor_agreement_url
    validate_url(:contributor_agreement_url)
  end

  def valid_video_url
    validate_url(:video_url)
    return if errors[:video_url].present?

    errors[:video_url] << "must be a Youtube link like 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'" if youtube_id.blank?
  end

  def valid_ethereum_enabled
    if ethereum_enabled_changed? && ethereum_enabled == false
      errors[:ethereum_enabled] << 'cannot be set to false after it has been set to true'
    end
  end

  def set_transitioned_to_ethereum_enabled
    @transitioned_to_ethereum_enabled = ethereum_enabled_changed? &&
                                        ethereum_enabled && ethereum_contract_address.blank?
    true # don't halt filter
  end

  def validate_url(attribute_name)
    uri = URI.parse(send(attribute_name) || '')
  rescue URI::InvalidURIError
    uri = nil
  ensure
    errors[attribute_name] << 'must be a valid url' unless uri&.absolute?
    uri
  end

  def maximum_tokens_unchanged
    if maximum_tokens_was > 0 && maximum_tokens_was != maximum_tokens
      errors[:maximum_tokens] << "can't be changed" if license_finalized? || ethereum_enabled?
    end
  end

  def ethereum_contract_address_exist_on_network?(symbol)
    if (ethereum_contract_address_changed? || ethereum_network_changed?) && symbol.blank?
      errors[:ethereum_contract_address] << 'should exist on the ethereum network'
    end
  end

  def check_contract_address_exist_on_blockchain_network
    if (contract_address_changed? || blockchain_network_changed?) && token_symbol.blank? && contract_address?
      errors[:contract_address] << 'should exist on the qtum network'
    end
  end

  def denomination_changeable
    errors.add(:denomination, 'cannot be changed because the license terms are finalized') if license_finalized_was
    errors.add(:denomination, 'cannot be changed because revenue has been recorded') if revenues.any? && denomination_changed?
  end

  def contract_address_changeable
    errors.add(:ethereum_network, 'cannot be changed if has completed transactions') if ethereum_network_changed?
    errors.add(:ethereum_contract_address, 'cannot be changed if has completed transactions') if ethereum_contract_address_changed?
    errors.add(:decimal_places, 'cannot be changed if has completed transactions') if decimal_places_changed?
  end

  def currency_precision
    Comakery::Currency::PRECISION[denomination]
  end
end
