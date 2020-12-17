class BlockchainTransactionAccountTokenRecord < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  def on_chain
    # TODO: Add algorand support

    @on_chain ||= Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions.new(token.blockchain.explorer_api_host, tx_hash)
  end

  private

    def tx
      @tx ||= contract.setAddressPermissions(
        blockchain_transactable.account.address_for_blockchain(token._blockchain),
        blockchain_transactable.reg_group.blockchain_id,
        blockchain_transactable.lockup_until.to_i,
        blockchain_transactable.max_balance,
        blockchain_transactable.account_frozen
      )
    end
end
