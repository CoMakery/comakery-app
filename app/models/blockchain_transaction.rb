class BlockchainTransaction < ApplicationRecord
  belongs_to :blockchain_transactable, polymorphic: true
  belongs_to :token
  has_many :updates, class_name: 'BlockchainTransactionUpdate', dependent: :destroy

  before_validation :populate_data
  before_validation :generate_transaction

  attr_readonly :amount, :source, :destination, :network, :contract_address, :current_block

  validates_with TxSupportTokenValidator
  validates :source, :network, :status, presence: true
  validates :contract_address, presence: true, if: -> { token.coin_type_token? }
  validates :tx_raw, :tx_hash, presence: true, if: -> { token.coin_type_comakery? && nonce.present? }

  enum network: { main: 0, ropsten: 1, kovan: 2, rinkeby: 3, constellation_mainnet: 4, constellation_testnet: 5 }
  enum status: { created: 0, pending: 1, cancelled: 2, succeed: 3, failed: 4 }

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

  def contract
    if token.coin_type_on_ethereum?
      @contract ||= Comakery::Eth::Contract::Erc20.new(contract_address, token.abi, network, nonce)
    else
      raise "Contract parsing is not implemented for #{token}"
    end
  end

  private

    def populate_data # rubocop:todo Metrics/CyclomaticComplexity
      self.token ||= blockchain_transactable.token

      if token.coin_type_on_ethereum?
        self.current_block ||= Comakery::Eth.new(token.ethereum_network).current_block
        self.contract_address ||= token.ethereum_contract_address
        self.network ||= token.ethereum_network
      else
        self.network ||= token.blockchain_network
      end
    end

    # @abstract Subclass is expected to implement #tx
    # @!method tx
    #    Return a new contract transaction instance for blockchain_transactable record

    def generate_transaction
      if token.coin_type_comakery? && nonce.present?
        self.tx_raw ||= tx.hex
        self.tx_hash ||= tx.hash
      end
    end
end
