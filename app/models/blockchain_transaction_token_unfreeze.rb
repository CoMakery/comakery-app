class BlockchainTransactionTokenUnfreeze < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(token_frozen: false)
  end

  def on_chain
    Comakery::Algorand::Tx::App::SecurityToken::Unfreeze.new(self)
  end

  private

    def tx
      nil
    end

    def populate_data
      super
      self.amount ||= 0
      self.source ||= '0'
      self.destination ||= '0'
    end
end
