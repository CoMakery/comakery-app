# Algorand Standard Assets Opt-in transactions
class BlockchainTransactionOptIn < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  def on_chain
    @on_chain ||= Comakery::Algorand.new(token.blockchain, contract_address)
  end
end
