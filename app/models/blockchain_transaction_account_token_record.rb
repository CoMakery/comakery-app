class BlockchainTransactionAccountTokenRecord < BlockchainTransaction
  has_many :blockchain_transactables_account_token_records, through: :transaction_batch, dependent: :nullify
  alias blockchain_transactables blockchain_transactables_account_token_records

  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  def update_transactable_prioritized_at(new_value = nil)
    return true unless transaction_batch

    blockchain_transactables.each do |bt|
      bt.update!(prioritized_at: new_value)
    end
  end

  # TODO: Refactor on_chain condition into TokenType
  def on_chain
    @on_chain ||= if token._token_type_on_ethereum?
      on_chain_eth
    elsif token._token_type_algorand_security_token?
      on_chain_ast
    end
  end

  def on_chain_eth
    Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions.new(token.blockchain.explorer_api_host, tx_hash, self)
  end

  def on_chain_ast
    Comakery::Algorand::Tx::App::SecurityToken::SetAddressPermissions.new(self)
  end

  def populate_data
    super
    self.destination ||= blockchain_transactable.wallet.address
  end
end
