class BlockchainTransaction < ApplicationRecord
  belongs_to :blockchain_transactable, polymorphic: true
  delegate :token, to: :blockchain_transactable
  has_many :updates, class_name: 'BlockchainTransactionUpdate'

  before_validation :populate_data
  before_validation :generate_transaction

  attr_readonly :amount, :source, :destination, :network, :contract_address, :current_block
  validates_with EthereumTokenValidator
  validates :amount, :source, :destination, :network, :status, :current_block, presence: true
  validates :contract_address, presence: true, if: -> { token.coin_type_token? }
  validates :tx_raw, :tx_hash, presence: true, if: -> { token.coin_type_comakery? && nonce.present? }

  enum network: %i[main ropsten kovan rinkeby]
  enum status: %i[created pending cancelled succeed failed]

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

      if blockchain_transactable.is_a?(Award)
        blockchain_transactable.update!(status: :paid) if status.to_s == 'succeed'
      end
    end
  end

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

  def on_chain
    @on_chain ||= if token.coin_type_token?
      case blockchain_transactable.source
      when 'mint'
        Comakery::Eth::Tx::Erc20::Mint.new(network, tx_hash)
      when 'burn'
        Comakery::Eth::Tx::Erc20::Burn.new(network, tx_hash)
      else
        Comakery::Eth::Tx::Erc20::Transfer.new(network, tx_hash)
      end
    else
      Comakery::Eth::Tx.new(network, tx_hash)
    end
  end

  def confirmed_on_chain?
    on_chain.confirmed?(self.class.number_of_confirmations)
  end

  def valid_on_chain?
    case on_chain
    when Comakery::Eth::Tx::Erc20::Mint, Comakery::Eth::Tx::Erc20::Burn, Comakery::Eth::Tx::Erc20::Transfer
      on_chain.valid?(source, contract_address, destination, amount, current_block)
    when Comakery::Eth::Tx
      on_chain.valid?(source, destination, amount, current_block)
    end
  end

  private

    def populate_data
      case blockchain_transactable
      when Award
        self.amount = token.to_base_unit(blockchain_transactable.total_amount)
        self.destination = blockchain_transactable.recipient_address
        self.network = token.ethereum_network
        self.contract_address = token.ethereum_contract_address
        self.current_block ||= Comakery::Eth.new(token.ethereum_network).current_block
      end
    end

    def contract
      @contract ||= Comakery::Eth::Contract::Erc20.new(contract_address, token.abi, network, nonce)
    end

    def tx
      @tx ||= case blockchain_transactable
              when Award
                case blockchain_transactable.source
                when 'mint'
                  contract.mint(destination, amount)
                when 'burn'
                  contract.burn(destination, amount)
                else
                  contract.transfer(destination, amount)
                end
      end
    end

    def generate_transaction
      if token.coin_type_comakery? && nonce.present?
        self.tx_raw ||= tx.hex
        self.tx_hash ||= tx.hash
      end
    end
end
