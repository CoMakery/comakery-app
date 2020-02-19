class Transaction < ApplicationRecord
  belongs_to :award
  has_one :token, through: :award
  has_many :states, class_name: 'TransactionState'
  has_one :current_state, -> { last }, class_name: 'TransactionState'

  before_validation :populate_data
  before_validation :generate_transaction
  after_create :create_state

  validates :amount, :source, :destination, :raw, :hash, :nonce, :network, :contract_address, presence: true
  validates_with ComakeryTokenValidator

  enum network: %i[main ropsten kovan rinkeby]

  BLOCKCHAIN_NUMBER_OF_CONFIRMATIONS = 1

  private

    def populate_data
      self.amount = award.total_amount
      self.destination = award.decorate.recipient_address
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
      self.raw = tx.hex
      self.hash = tx.hash
    end

    def create_state
      states.create!
    end
end
