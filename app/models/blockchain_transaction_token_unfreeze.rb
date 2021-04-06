class BlockchainTransactionTokenUnfreeze < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(token_frozen: false)
  end

  # TODO: Refactor on_chain condition into TokenType
  def on_chain
    @on_chain ||= if token._token_type_comakery_security_token?
      Comakery::Eth::Tx::Erc20::SecurityToken::Unpause.new(token.blockchain.explorer_api_host, tx_hash, self)
    elsif token._token_type_algorand_security_token?
      Comakery::Algorand::Tx::App::SecurityToken::Unpause.new(self)
    end
  end

  private

    def populate_data
      super
      self.amount ||= 0
      self.source ||= '0'
      self.destination ||= '0'
    end
end
