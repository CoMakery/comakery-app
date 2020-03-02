class BlockchainTransaction < ApplicationRecord
  belongs_to :award
  has_one :token, through: :award
  has_many :updates, class_name: 'BlockchainTransactionUpdate'

  before_validation :populate_data
  before_validation :generate_transaction

  attr_readonly :amount, :source, :destination, :tx_raw, :tx_hash, :nonce, :network, :contract_address
  validates :amount, :source, :destination, :tx_raw, :tx_hash, :nonce, :network, :contract_address, :status, presence: true
  validates_with ComakeryTokenValidator

  enum network: %i[main ropsten kovan rinkeby]
  enum status: %i[created pending cancelled succeed failed]

  def self.number_of_confirmations
    ENV.fetch('BLOCKCHAIN_TX__NUMBER_OF_CONFIRMATIONS', 3).to_i
  end

  def self.seconds_to_wait_between_syncs
    ENV.fetch('BLOCKCHAIN_TX__SECONDS_TO_WAIT_BETWEEN_SYNCS', 10).to_i
  end

  def self.max_syncs
    ENV.fetch('BLOCKCHAIN_TX__MAX_SYNCS', 60).to_i
  end

  def update_status(new_status, new_message = nil)
    if update!(status: new_status, status_message: new_message)
      updates.create!(status: status, status_message: status_message)

      award.update!(status: :paid) if status.to_s == 'succeed'
    end
  end

  def sync
    case contract.tx_status(tx_hash, self.class.number_of_confirmations)
    when 0
      update_status(:failed)
    when 1
      update_status(:succeed)
    else
      false
    end
  ensure
    update_number_of_syncs
  end

  def reached_max_syncs?
    number_of_syncs >= self.class.max_syncs
  end

  def waiting_till_next_sync_is_allowed?
    synced_at && (synced_at + self.class.seconds_to_wait_between_syncs > Time.current)
  end

  def update_number_of_syncs
    update(number_of_syncs: number_of_syncs + 1, synced_at: Time.current)
    update_status(:failed, 'max_syncs') if pending? && reached_max_syncs?
  end

  private

    def populate_data
      self.amount = token.to_base_unit(award.total_amount)
      self.destination = award.recipient_address
      self.network = token.ethereum_network
      self.contract_address = token.ethereum_contract_address
    end

    def contract
      @contract ||= Comakery::Erc20.new(contract_address, token.abi, network, nonce)
    end

    def tx
      @tx ||= case award.source
              when 'mint'
                contract.mint(destination, amount)
              when 'burn'
                contract.burn(destination, amount)
              else
                contract.transfer(destination, amount)
      end
    end

    def generate_transaction
      self.tx_raw ||= tx.hex
      self.tx_hash ||= tx.hash
    end
end
