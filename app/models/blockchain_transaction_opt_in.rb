# Algorand Standard Assets Opt-in transactions
class BlockchainTransactionOptIn < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :opted_in)
  end

  def on_chain
    @on_chain ||= Comakery::Algorand::Tx::Asset.new(token.blockchain, tx_hash, contract_address)
  end

  private

    def populate_data
      super
      self.amount ||= 0
      self.destination ||= blockchain_transactable.wallet.address
      self.source ||= blockchain_transactable.wallet.address
      self.token ||= blockchain_transactable.token
    end
end
