class BlockchainTransactionTransferRule < BlockchainTransaction
  has_many :blockchain_transactables_transfer_rules, through: :transaction_batch, dependent: :nullify
  alias blockchain_transactables blockchain_transactables_transfer_rules

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
