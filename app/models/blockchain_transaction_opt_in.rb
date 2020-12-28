# Algorand Standard Assets and Apps (Algorand Security Token) Opt-in transactions
class BlockchainTransactionOptIn < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :opted_in)
  end

  def on_chain
    @on_chain ||=
      begin
        if token._token_type_asa?
          Comakery::Algorand::Tx::Asset::OptIn.new(self)
        elsif token._token_type_algorand_security_token?
          Comakery::Algorand::Tx::App::OptIn.new(self)
        end
      end
  end

  private

    def populate_data
      super
      self.amount ||= 0
      self.source ||= blockchain_transactable.wallet.address
      self.token ||= blockchain_transactable.token
      self.destination ||= blockchain_transactable.wallet.address if token._token_type_asa?
    end
end
