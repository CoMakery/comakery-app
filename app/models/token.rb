class Token < ApplicationRecord
  nilify_blanks

  attachment :logo_image, type: :image

  has_many :projects
  has_many :accounts, through: :projects, source: :interested
  has_many :account_token_records
  has_many :reg_groups
  has_many :transfer_rules
  has_many :transfer_rules_synced, -> { where synced: true }
  has_many :blockchain_transactions

  validates :name, uniqueness: true
  validates :name, :symbol, :decimal_places, :_blockchain, :_token_type, :denomination, presence: true
  validate :valid_contract_address, if: -> { token_type.operates_with_smart_contracts? }

  before_validation :set_values_from_token_type
  after_create :default_reg_group, if: -> { token_type.operates_with_reg_groups? }

  scope :listed, -> { where unlisted: false }

  enum denomination: {
    USD: 0,
    BTC: 1,
    ETH: 2
  }
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
  }, _prefix: :coin_type # Deprecated
  enum ethereum_network: {
    main:    'Main Ethereum Network',
    ropsten: 'Ropsten Test Network',
    kovan:   'Kovan Test Network',
    rinkeby: 'Rinkeby Test Network'
  }, _prefix: :deprecated # Deprecated
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
  } # Deprecated

  enum _blockchain: Blockchain.list, _prefix: :_blockchain
  enum _token_type: TokenType.list, _prefix: :_token_type

  delegate :contract, :abi, to: :token_type

  def self.blockchain_for(name)
    "Blockchain::#{name.camelize}".constantize.new
  end

  def blockchain
    @blockchain ||= "Blockchain::#{_blockchain.camelize}".constantize.new
  end

  def blockchain_name_for_wallet
    blockchain.name.match(/^([A-Z][a-z]+)[A-Z]/)[1].downcase
  end

  def token_type
    @token_type ||= "TokenType::#{_token_type.camelize}".constantize.new(
      blockchain: blockchain,
      contract_address: contract_address
    )
  end

  def _token_type_token?
    token_type.operates_with_smart_contracts?
  end

  def _token_type_on_ethereum?
    blockchain.name.match?(/^Ethereum/)
  end

  def _token_type_on_qtum?
    blockchain.name.match?(/^Qtum/)
  end

  def to_base_unit(amount)
    BigDecimal(10.pow(decimal_places || 0) * amount)&.to_s&.to_i
  end

  def default_reg_group
    RegGroup.default_for(self)
  end

  private

    def set_values_from_token_type
      self.name ||= token_type.name
      self.symbol ||= token_type.symbol
      self.decimal_places ||= token_type.decimals

      self.ethereum_enabled ||= (token_type.operates_with_smart_contracts? && _token_type_on_ethereum?) # Deprecated
    end

    def valid_contract_address
      blockchain.validate_addr(contract_address)
    rescue Blockchain::Address::ValidationError => e
      errors.add(:contract_address, e.message)
    end
end
