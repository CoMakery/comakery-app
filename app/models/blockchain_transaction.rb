class BlockchainTransaction < ApplicationRecord
  belongs_to :blockchain_transactable, polymorphic: true
  belongs_to :token
  has_many :updates, class_name: 'BlockchainTransactionUpdate', dependent: :destroy

  before_validation :populate_data
  before_validation :generate_transaction

  attr_readonly :amount, :source, :destination, :network, :contract_address, :current_block

  validates_with TxSupportTokenValidator
  validates :source, :network, :status, presence: true
  validates :contract_address, presence: true, if: -> { token.token_type.operates_with_smart_contracts? }
  validates :tx_raw, presence: true, if: -> { generate_algo_transaction? || generate_eth_transaction? }
  validates :tx_hash, presence: true, if: -> { pending? || succeed? }

  enum status: { created: 0, pending: 1, cancelled: 2, succeed: 3, failed: 4 }
  enum network: { ethereum: 0, ethereum_ropsten: 1, ethereum_kovan: 2, ethereum_rinkeby: 3, constellation: 4, constellation_test: 5, algorand: 6, algorand_test: 7, algorand_beta: 8 }

  validates :network, inclusion: { in: networks.keys.map(&:to_s), message: 'unknown network value' }

  def self.number_of_confirmations
    ENV.fetch('BLOCKCHAIN_TX__NUMBER_OF_CONFIRMATIONS', 3).to_i
  end

  def self.seconds_to_wait_between_syncs
    ENV.fetch('BLOCKCHAIN_TX__SECONDS_TO_WAIT_BETWEEN_SYNCS', 10).to_i
  end

  def self.seconds_to_wait_in_created
    ENV.fetch('BLOCKCHAIN_TX__SECONDS_TO_WAIT_IN_CREATED', 600).to_i
  end

  def self.max_syncs
    ENV.fetch('BLOCKCHAIN_TX__MAX_SYNCS', 60).to_i
  end

  def self.migrate_awards_to_blockchain_transactable
    BlockchainTransaction.where.not(award_id: nil).find_each do |t|
      t.update!(blockchain_transactable_id: t.award_id, blockchain_transactable_type: 'Award')
    end
  end

  def update_status(new_status, new_message = nil)
    if update!(status: new_status, status_message: new_message)
      updates.create!(status: status, status_message: status_message)

      update_transactable_status if succeed?
    end
  end

  # @abstract Subclass is expected to implement #update_transactable_status
  # @!method update_transactable_status
  #    Update status of blockchain_transactable record

  def sync
    return false unless confirmed_on_chain?

    if valid_on_chain?
      update_status(:succeed)
    else
      update_status(:failed, 'Failed on chain')
    end
  ensure
    update_number_of_syncs
  end

  def reached_max_syncs?
    number_of_syncs >= self.class.max_syncs
  end

  def waiting_in_created?
    created? && (created_at + self.class.seconds_to_wait_in_created > Time.current)
  end

  def waiting_till_next_sync_is_allowed?
    synced_at && (synced_at + self.class.seconds_to_wait_between_syncs > Time.current)
  end

  def update_number_of_syncs
    update(number_of_syncs: number_of_syncs + 1, synced_at: Time.current)
    update_status(:cancelled, 'max_syncs') if pending? && reached_max_syncs?
  end

  # @abstract Subclass is expected to implement #on_chain
  # @!method on_chain
  #    Return a Comakery::*::Tx instance for blockchain_transactable record

  def confirmed_on_chain?
    on_chain.confirmed?(self.class.number_of_confirmations)
  end

  def valid_on_chain?
    on_chain.valid?(self)
  end

  # TODO: Move the logic into on_chain
  def contract
    if token._token_type_on_ethereum?
      @contract ||= Comakery::Eth::Contract::Erc20.new(contract_address, token.abi, token.blockchain.explorer_api_host, nonce)
    else
      raise "Contract parsing is not implemented for #{token}"
    end
  end

  def populate_data
    self.token ||= blockchain_transactable.token
    self.contract_address ||= token.contract_address
    self.network ||= token._blockchain
    self.current_block ||= token.blockchain.current_block
  end

  def generate_transaction
    generate_algo_transaction if generate_algo_transaction?
    generate_eth_transaction if generate_eth_transaction?
  end

  def generate_algo_transaction?
    token.blockchain.is_a?(Blockchain::Algorand)
  end

  def generate_algo_transaction
    self.tx_raw ||= on_chain.to_object(app_args_format: :hex).to_json
  end

  # TODO: Refactor generate_eth_transaction into ETH tx subclasses
  # and call via on_chain similar to algo
  def generate_eth_transaction?
    token._token_type_comakery_security_token? && nonce.present? && tx.present?
  end

  # @abstract Subclass is expected to implement #tx
  # @!method tx
  #    Return a new contract transaction instance for blockchain_transactable record

  # TODO: Refactor generate_eth_transaction into ETH tx subclasses
  # and call via on_chain similar to algo
  def generate_eth_transaction
    self.tx_raw ||= tx.hex
    self.tx_hash ||= tx.hash
  end

  # Overwrite the setter to rely on validations instead of [ArgumentError]
  def network=(value)
    super
  rescue ArgumentError
    # Skip argument and reset `network`
    self.network = nil
  end
end
