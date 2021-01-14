class BlockchainTransactionAccountTokenRecord < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  def on_chain
    @on_chain ||= if token._token_type_on_ethereum?
      on_chain_eth
    elsif token._token_type_algorand_security_token?
      on_chain_ast
    end
  end

  def on_chain_eth
    Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions.new(token.blockchain.explorer_api_host, tx_hash)
  end

  def on_chain_ast
    Comakery::Algorand::Tx::App::SecurityToken::TransferRestrictions.new(self)
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
