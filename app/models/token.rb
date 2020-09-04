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
    xtz: 'tezos',
    dag: 'constellation'
  }.freeze

  COIN_DECIMALS = {
    eth: 18,
    qtum: 8,
    ada: 6,
    btc: 8,
    eos: 18,
    xtz: 6,
    dag: 8
  }.freeze

  COIN_NAMES = {
    eth: 'Ether',
    qtum: 'Qtum',
    ada: 'Cardano',
    btc: 'Bitcoin',
    eos: 'EOSIO',
    xtz: 'Tezos',
    dag: 'DAG'
  }.freeze

  nilify_blanks
  attachment :logo_image, type: :image

  has_many :projects
  has_many :accounts, through: :projects, source: :interested
  has_many :account_token_records
  has_many :reg_groups
  has_many :transfer_rules
  has_many :transfer_rules_synced, -> { where synced: true }
  has_many :blockchain_transactions

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
    comakery: 'Comakery Security Token',
    dag: 'DAG'
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
  }, _prefix: :deprecated

  enum blockchain_network: {
    bitcoin_mainnet: 'Main Bitcoin Network',
    bitcoin_testnet: 'Test Bitcoin Network',
    cardano_mainnet: 'Main Cardano Network',
    cardano_testnet: 'Test Cardano Network',
    qtum_mainnet: 'Main QTUM Network',
    qtum_testnet: 'Test QTUM Network',
    eos_mainnet: 'Main EOS Network',
    eos_testnet: 'Test EOS Network',
    tezos_mainnet: 'Main Tezos Network',
    constellation_mainnet: 'Main Constellation Network',
    constellation_testnet: 'Test Constellation Network',
    main:    'Main Ethereum Network',
    ropsten: 'Ropsten Test Network',
    kovan:   'Kovan Test Network',
    rinkeby: 'Rinkeby Test Network'
  }

  validates :name, :denomination, presence: true
  validates :name, uniqueness: true

  validate :valid_ethereum_enabled
  validate :check_contract_address_exist_on_blockchain_network
  validates :contract_address, presence: true

  before_validation :populate_token_symbol
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
    coin_type_on_ethereum? && blockchain_network.present? && contract_address.present? && (symbol.blank? || decimal_places.blank?)
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

  def set_predefined_values
    if coin_type && !coin_type_token?
      self.name = COIN_NAMES[coin_type.to_sym]
      self.symbol = coin_type.upcase
      self.decimal_places = COIN_DECIMALS[coin_type.to_sym]
    end
  end

  def populate_token_symbol
    if populate_token?
      web3 = Comakery::Web3.new(blockchain_network)
      symbol, decimals = web3.fetch_symbol_and_decimals(contract_address)
      self.symbol = symbol if symbol.blank?
      self.decimal_places = decimals if decimal_places.blank?
      contract_address_exist_on_network?(symbol)
    end
  end

  def enable_ethereum
    self.ethereum_enabled = contract_address.present? unless ethereum_enabled
  end

  def set_transitioned_to_ethereum_enabled
    @transitioned_to_ethereum_enabled = ethereum_enabled_changed? &&
                                        ethereum_enabled && contract_address.blank?
    true # don't halt filter
  end

  def valid_ethereum_enabled
    if ethereum_enabled_changed? && ethereum_enabled == false
      errors[:ethereum_enabled] << 'cannot be set to false after it has been set to true'
    end
  end

  def contract_address_exist_on_network?(symbol)
    if (contract_address_changed? || blockchain_network_changed?) && symbol.blank? && contract_address?
      errors[:contract_address] << 'should exist on the ethereum network'
    end
  end

  def check_contract_address_exist_on_blockchain_network
    if (contract_address_changed? || blockchain_network_changed?) && symbol.blank? && contract_address?
      errors[:contract_address] << 'should exist on the qtum network'
    end
  end
end
