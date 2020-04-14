class Token < ApplicationRecord
  include EthereumAddressable
  include QtumContractAddressable

  BLOCKCHAIN_NAMES = {
    erc20: 'ethereum',
    eth: 'ethereum',
    comakery: 'ethereum',
    qrc20: 'qtum',
    qtum: 'qtum',
    ada: 'cardano',
    btc: 'bitcoin',
    eos: 'eos',
    xtz: 'tezos'
  }.freeze

  COIN_DECIMALS = {
    eth: 18,
    qtum: 8,
    ada: 6,
    btc: 8,
    eos: 18,
    xtz: 6
  }.freeze

  COIN_NAMES = {
    eth: 'Ether',
    qtum: 'Qtum',
    ada: 'Cardano',
    btc: 'Bitcoin',
    eos: 'EOSIO',
    xtz: 'Tezos'
  }.freeze

  nilify_blanks
  attachment :logo_image, type: :image

  has_many :projects
  has_many :accounts, through: :projects, source: :interested
  has_many :account_token_records
  has_many :reg_groups
  has_many :transfer_rules

  # TODO: Uncomment when according migrations are finished (TASKS, BATCHES)
  # has_many :batches
  # has_many :tasks, through: :batches, dependent: :destroy
  # has_many :completed_tasks, -> { where.not ethereum_transaction_address: nil }, through: :batches, source: :tasks

  scope :listed, -> { where unlisted: false }

  enum coin_type: {
    erc20: 'ERC20',
    eth: 'ETH',
    qrc20: 'QRC20',
    qtum:  'QTUM',
    ada: 'ADA',
    btc: 'BTC',
    eos: 'EOS',
    xtz: 'XTZ',
    comakery: 'Comakery Security Token'
  }, _prefix: :coin_type

  enum denomination: {
    USD: 0,
    BTC: 1,
    ETH: 2
  }

  enum ethereum_network: {
    main:    'Main Ethereum Network',
    ropsten: 'Ropsten Test Network',
    kovan:   'Kovan Test Network',
    rinkeby: 'Rinkeby Test Network'
  }

  enum blockchain_network: {
    bitcoin_mainnet: 'Main Bitcoin Network',
    bitcoin_testnet: 'Test Bitcoin Network',
    cardano_mainnet: 'Main Cardano Network',
    cardano_testnet: 'Test Cardano Network',
    qtum_mainnet: 'Main QTUM Network',
    qtum_testnet: 'Test QTUM Network',
    eos_mainnet: 'Main EOS Network',
    eos_testnet: 'Test EOS Network',
    tezos_mainnet: 'Main Tezos Network'
  }

  validates :name, :denomination, presence: true
  validates :name, uniqueness: true

  validate :valid_ethereum_enabled
  validate :check_contract_address_exist_on_blockchain_network
  validates :contract_address, qtum_contract_address: true # see QtumContractAddressable
  validates :ethereum_contract_address, ethereum_address: { type: :account } # see EthereumAddressable

  # TODO: Uncomment when according migrations are finished (TASKS, BATCHES)
  # validate :denomination_changeable, if: -> { tasks.present? }
  # validate :contract_address_changeable, if: -> { tasks.present? }

  before_validation :populate_token_symbol
  before_validation :check_coin_type
  before_validation :set_predefined_values
  before_save :set_transitioned_to_ethereum_enabled
  before_save :enable_ethereum
  after_create :default_reg_group, if: -> { coin_type_comakery? }

  def coin_type_token?
    coin_type_erc20? || coin_type_qrc20? || coin_type_comakery?
  end

  def coin_type_on_ethereum?
    coin_type_erc20? || coin_type_eth? || coin_type_comakery?
  end

  def coin_type_on_qtum?
    coin_type_qrc20? || coin_type_qtum?
  end

  def transitioned_to_ethereum_enabled?
    @transitioned_to_ethereum_enabled
  end

  def decimal_places_value
    10**decimal_places.to_i
  end

  def populate_token?
    coin_type_on_ethereum? && ethereum_network.present? && ethereum_contract_address.present? && (symbol.blank? || decimal_places.blank?)
  end

  def abi
    if coin_type_comakery?
      JSON.parse(File.read(Rails.root.join('vendor', 'abi', 'coin_types', 'comakery.json')))
    else
      JSON.parse(File.read(Rails.root.join('vendor', 'abi', 'coin_types', 'default.json')))
    end
  end

  def to_base_unit(amount)
    BigDecimal(10.pow(decimal_places || 0) * amount)&.to_s&.to_i
  end

  def default_reg_group
    RegGroup.default_for(self)
  end

  private

  def check_coin_type
    check_coin_type_blockchain_network
    if coin_type_erc20?
      self.contract_address = nil
    elsif coin_type_comakery?
      self.contract_address = nil
    elsif coin_type_qrc20?
      self.ethereum_contract_address = nil
    elsif coin_type?
      self.contract_address = nil
      self.ethereum_contract_address = nil
      self.symbol = nil
      self.decimal_places = nil
    end
  end

  def set_predefined_values
    if coin_type && !coin_type_token?
      self.name = COIN_NAMES[coin_type.to_sym]
      self.symbol = coin_type.upcase
      self.decimal_places = COIN_DECIMALS[coin_type.to_sym]
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
      web3 = Comakery::Web3.new(ethereum_network)
      symbol, decimals = web3.fetch_symbol_and_decimals(ethereum_contract_address)
      self.symbol = symbol if symbol.blank?
      self.decimal_places = decimals if decimal_places.blank?
      ethereum_contract_address_exist_on_network?(symbol)
    end
  end

  def enable_ethereum
    self.ethereum_enabled = ethereum_contract_address.present? || contract_address? unless ethereum_enabled
  end

  def set_transitioned_to_ethereum_enabled
    @transitioned_to_ethereum_enabled = ethereum_enabled_changed? &&
                                        ethereum_enabled && ethereum_contract_address.blank?
    true # don't halt filter
  end

  def valid_ethereum_enabled
    if ethereum_enabled_changed? && ethereum_enabled == false
      errors[:ethereum_enabled] << 'cannot be set to false after it has been set to true'
    end
  end

  def ethereum_contract_address_exist_on_network?(symbol)
    if (ethereum_contract_address_changed? || ethereum_network_changed?) && symbol.blank? && ethereum_contract_address?
      errors[:ethereum_contract_address] << 'should exist on the ethereum network'
    end
  end

  def check_contract_address_exist_on_blockchain_network
    if (contract_address_changed? || blockchain_network_changed?) && symbol.blank? && contract_address?
      errors[:contract_address] << 'should exist on the qtum network'
    end
  end

  # TODO: Uncomment when according migrations are finished (TASKS, BATCHES)
  # def denomination_changeable
  #   errors.add(:blockchain_network, 'cannot be changed if has associated tasks') if denomination_changed?
  # end

  # def contract_address_changeable
  #   ethereum_contract_address_changeable
  #   errors.add(:blockchain_network, 'cannot be changed if has associated tasks') if blockchain_network_changed?
  #   errors.add(:contract_address, 'cannot be changed if has associated tasks') if contract_address_changed?
  #   errors.add(:decimal_places, 'cannot be changed if has associated tasks') if decimal_places_changed?
  # end

  # def ethereum_contract_address_changeable
  #   errors.add(:ethereum_network, 'cannot be changed if has associated tasks') if ethereum_network_changed?
  #   errors.add(:ethereum_contract_address, 'cannot be changed if has associated tasks') if ethereum_contract_address_changed?
  # end
end
