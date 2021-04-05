class BlockchainTransactionTokenFreeze < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(token_frozen: true)
  end

  # TODO: Refactor on_chain condition into TokenType
  def on_chain
    @on_chain ||= if token._token_type_comakery_security_token?
      Comakery::Eth::Tx::Erc20::SecurityToken::Pause.new(token.blockchain.explorer_api_host, tx_hash, self)
    elsif token._token_type_algorand_security_token?
      Comakery::Algorand::Tx::App::SecurityToken::Pause.new(self)
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
