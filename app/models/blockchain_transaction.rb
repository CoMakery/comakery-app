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

  NUMBER_OF_CONFIRMATIONS = 3

  def update_status(new_status, new_message = nil)
    if update!(status: new_status, status_message: new_message)
      updates.create!(status: status, status_message: status_message)

      award.update!(status: :paid) if status.to_s == 'succeed'
    end
  end

  def sync
    case contract.tx_status(tx_hash, NUMBER_OF_CONFIRMATIONS)
    when 0
      update_status(:failed)
    when 1
      update_status(:succeed)
    else
      false
    end
  end

  private

    def populate_data
      self.amount = award.total_amount
      self.destination = award.recipient_address
      self.network = token.ethereum_network
      self.contract_address = token.ethereum_contract_address
    end

    def contract
      @contract ||= Comakery::Erc20.new(contract_address, token.abi, network, nonce)
    end

    def tx
      f = Ethereum::Formatter.new

      @tx ||= case award.source
              when 'mint'
                contract.mint(destination, f.to_wei(amount))
              when 'burn'
                contract.burn(destination, f.to_wei(amount))
              else
                contract.transfer(destination, f.to_wei(amount))
      end
    end

    def generate_transaction
      self.tx_raw ||= tx.hex
      self.tx_hash ||= tx.hash
    end
end
