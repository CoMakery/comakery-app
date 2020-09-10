class BlockchainTransactionTransferRule < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  def on_chain
    @on_chain ||= Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer.new(token.blockchain.explorer_api_host, tx_hash)
  end

  private

    def tx
      @tx ||= contract.setAllowGroupTransfer(
        blockchain_transactable.sending_group.blockchain_id,
        blockchain_transactable.receiving_group.blockchain_id,
        blockchain_transactable.lockup_until.to_i
      )
    end
end
