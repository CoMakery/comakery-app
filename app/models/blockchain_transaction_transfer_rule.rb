class BlockchainTransactionTransferRule < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  # TODO: Refactor on_chain condition into TokenType
  def on_chain
    @on_chain ||= if token._token_type_comakery_security_token?
      Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer.new(token.blockchain.explorer_api_host, tx_hash, self)
    elsif token._token_type_algorand_security_token?
      Comakery::Algorand::Tx::App::SecurityToken::SetTransferRule.new(self)
    end
  end
end
