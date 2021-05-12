class BlockchainTransactionOptIn < BlockchainTransaction
  has_many :blockchain_transactables_token_opt_ins, through: :transaction_batch, dependent: :nullify
  alias blockchain_transactables blockchain_transactables_token_opt_ins

  def update_transactable_status
    blockchain_transactable.update!(status: :opted_in)
  end

  # TODO: Refactor on_chain condition into TokenType
  def on_chain
    @on_chain ||=
      begin
        if token._token_type_asa?
          Comakery::Algorand::Tx::Asset::OptIn.new(self)
        elsif token._token_type_algorand_security_token?
          Comakery::Algorand::Tx::App::OptIn.new(self)
        end
      end
  end

  private

    def populate_data
      super
      self.amount ||= 0
      self.source ||= blockchain_transactable.wallet.address
      self.token ||= blockchain_transactable.token
      self.destination ||= blockchain_transactable.wallet.address if token._token_type_asa?
    end
end
