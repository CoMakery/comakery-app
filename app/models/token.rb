class Token < ApplicationRecord
  nilify_blanks

  attachment :logo_image, type: :image

  has_many :projects # rubocop:todo Rails/HasManyOrHasOneDependent
  has_many :accounts, through: :projects, source: :interested
  has_many :account_token_records # rubocop:todo Rails/HasManyOrHasOneDependent
  has_many :reg_groups # rubocop:todo Rails/HasManyOrHasOneDependent
  has_many :transfer_rules # rubocop:todo Rails/HasManyOrHasOneDependent
  has_many :transfer_rules_synced, -> { where synced: true } # rubocop:todo Rails/InverseOf
  has_many :blockchain_transactions # rubocop:todo Rails/HasManyOrHasOneDependent

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
    qtum: 'QTUM',
    ada: 'ADA',
    btc: 'BTC',
    eos: 'EOS',
    xtz: 'XTZ',
    comakery: 'Comakery Security Token',
    dag: 'DAG'
  }, _prefix: :coin_type # Deprecated
  enum ethereum_network: {
    main: 'Main Ethereum Network',
    ropsten: 'Ropsten Test Network',
    kovan: 'Kovan Test Network',
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
    blockchain.name.match(/^([A-Z][a-z]+)[A-Z]*/)[1].downcase
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

<<<<<<< HEAD
  def _token_type_on_qtum?
    blockchain.name.match?(/^Qtum/)
=======
  def abi
    if coin_type_comakery?
      # rubocop:todo Rails/FilePath
      JSON.parse(File.read(Rails.root.join('vendor', 'abi', 'coin_types', 'comakery.json')))
      # rubocop:enable Rails/FilePath
    else
      # rubocop:todo Rails/FilePath
      JSON.parse(File.read(Rails.root.join('vendor', 'abi', 'coin_types', 'default.json')))
      # rubocop:enable Rails/FilePath
    end
>>>>>>> acceptance
  end

  def to_base_unit(amount)
    BigDecimal(10.pow(decimal_places || 0) * amount)&.to_s&.to_i
  end

  def default_reg_group
    RegGroup.default_for(self)
  end

  private

<<<<<<< HEAD
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
=======
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
      errors[:ethereum_enabled] << 'cannot be set to false after it has been set to true' if ethereum_enabled_changed? && ethereum_enabled == false
    end

    def ethereum_contract_address_exist_on_network?(symbol)
      errors[:ethereum_contract_address] << 'should exist on the ethereum network' if (ethereum_contract_address_changed? || ethereum_network_changed?) && symbol.blank? && ethereum_contract_address?
    end

    def check_contract_address_exist_on_blockchain_network
      errors[:contract_address] << 'should exist on the qtum network' if (contract_address_changed? || blockchain_network_changed?) && symbol.blank? && contract_address?
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
>>>>>>> acceptance
end
