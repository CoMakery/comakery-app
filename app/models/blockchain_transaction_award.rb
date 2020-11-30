class BlockchainTransactionAward < BlockchainTransaction
  validates :destination, presence: true

  def update_transactable_status
    blockchain_transactable.update!(status: :paid)
  end

  def on_chain # rubocop:todo Metrics/CyclomaticComplexity
    @on_chain ||= if token._token_type_on_ethereum?
      on_chain_eth
    elsif token._token_type_dag?
      on_chain_dag
    elsif token._token_type_algo? || token._token_type_asa?
      on_chain_algo
    end
  end

  private

    def on_chain_eth
      if token._token_type_token?
        case blockchain_transactable.transfer_type.name
        when 'mint'
          Comakery::Eth::Tx::Erc20::Mint.new(token.blockchain.explorer_api_host, tx_hash)
        when 'burn'
          Comakery::Eth::Tx::Erc20::Burn.new(token.blockchain.explorer_api_host, tx_hash)
        else
          Comakery::Eth::Tx::Erc20::Transfer.new(token.blockchain.explorer_api_host, tx_hash)
        end
      else
        Comakery::Eth::Tx.new(token.blockchain.explorer_api_host, tx_hash)
      end
    end

    def on_chain_dag
      Comakery::Dag::Tx.new(token.blockchain.explorer_api_host, tx_hash)
    end

    def on_chain_algo
      if token._token_type_algo?
        Comakery::Algorand::Tx.new(token.blockchain, tx_hash)
      elsif token._token_type_asa?
        Comakery::Algorand::Tx::Asset.new(token.blockchain, tx_hash, contract_address)
      end
    end

    def populate_data
      super
      self.amount ||= token.to_base_unit(blockchain_transactable.total_amount)
      self.destination ||= blockchain_transactable.recipient_address
      self.current_block ||= Comakery::Algorand.new(token.blockchain).last_round if token._token_type_algo? || token._token_type_asa?
    end

    def tx
      @tx ||= destination && case blockchain_transactable.source
                             when 'mint'
                               contract.mint(destination, amount)
                             when 'burn'
                               contract.burn(destination, amount)
                             else
                               contract.transfer(destination, amount)
                             end
    end
end
