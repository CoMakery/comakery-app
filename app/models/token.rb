class Token < ApplicationRecord
  include EthereumAddressable
  include QtumContractAddressable

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

  enum _blockchain: Blockchain.list, _prefix: :_blockchain
  enum _token_type: TokenType.list, _prefix: :_token_type

  validates :name, :denomination, presence: true
  validates :name, uniqueness: true
  validates :contract_address, presence: true

  before_validation :populate_token_symbol
  before_validation :set_predefined_values
  before_save :enable_ethereum
  after_create :default_reg_group, if: -> { _token_type_comakery_security_token? }

  def self.blockchain_for(name)
    "Blockchain::#{name.camelize}".constantize.new
  end

  def blockchain
    "Blockchain::#{_blockchain.camelize}".constantize.new
  end

  def token_type
    "TokenType::#{_token_type.camelize}".constantize.new(
      contract_address: contract_address,
      abi: abi,
      blockchain: blockchain
    )
  end

  def _token_type_token?
    _token_type_erc20? || _token_type_qrc20? || _token_type_comakery_security_token?
  end

  def _token_type_on_ethereum?
    _token_type_erc20? || _token_type_eth? || _token_type_comakery_security_token?
  end

  def _token_type_on_qtum?
    _token_type_qrc20? || _token_type_qtum?
  end

  def decimal_places_value
    10**decimal_places.to_i
  end

  def populate_token?
    _token_type_on_ethereum? && _blockchain.present? && contract_address.present? && (symbol.blank? || decimal_places.blank?)
  end

  def abi
    if _token_type_comakery_security_token?
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
    if _token_type && !_token_type_token?
      self.name = token_type.name
      self.symbol = token_type.symbol
      self.decimal_places = token_type.decimals
    end
  end

  def populate_token_symbol
    if populate_token?
      web3 = Comakery::Web3.new(blockchain.explorer_api_host)
      symbol, decimals = web3.fetch_symbol_and_decimals(contract_address)
      self.symbol = symbol if symbol.blank?
      self.decimal_places = decimals if decimal_places.blank?
      contract_address_exist_on_network?(symbol)
    end
  end

  def enable_ethereum
    self.ethereum_enabled = contract_address.present? && _token_type_on_ethereum?
  end
end
