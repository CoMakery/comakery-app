class BlockchainTransactionAward < BlockchainTransaction
  validates :destination, presence: true
  after_update :broadcast_updates

  has_many :blockchain_transactables_awards, through: :transaction_batch, dependent: :nullify
  alias blockchain_transactables blockchain_transactables_awards

  def update_transactable_status
    blockchain_transactables.each do |blockchain_transactable|
      blockchain_transactable.update!(status: :paid)
    end
  end

  def update_transactable_prioritized_at(new_value = nil)
    return unless transaction_batch

    blockchain_transactables.each do |bt|
      bt.update!(prioritized_at: new_value)
    end
    true
  end

  # TODO: Refactor on_chain condition into TokenType
  def on_chain # rubocop:todo Metrics/CyclomaticComplexity
    @on_chain ||= if token._token_type_on_ethereum?
      on_chain_eth
    elsif token._token_type_dag?
      on_chain_dag
    elsif token._token_type_algo?
      on_chain_algo
    elsif token._token_type_asa?
      on_chain_asa
    elsif token._token_type_algorand_security_token?
      on_chain_ast
    end
  end

  def broadcast_updates
    blockchain_transactables.each do |blockchain_transactable|
      broadcast_replace_later_to(
        blockchain_transactable,
        :updates,
        target: "transfer_history_button_#{blockchain_transactable.id}",
        partial: 'dashboard/transfers/transfer_history_button',
        locals: { transfer: blockchain_transactable }
      )

      broadcast_replace_later_to(
        blockchain_transactable,
        :updates,
        target: "transfer_issuer_#{blockchain_transactable.id}",
        partial: 'dashboard/transfers/issuer',
        locals: { transfer: blockchain_transactable.decorate }
      )

      broadcast_replace_later_to(
        blockchain_transactable,
        :updates,
        target: "transfer_recipient_#{blockchain_transactable.id}",
        partial: 'dashboard/transfers/recipient',
        locals: { transfer: blockchain_transactable.decorate }
      )

      broadcast_replace_later_to(
        blockchain_transactable,
        :updates,
        target: "transfer_button_public_#{blockchain_transactable.id}",
        partial: 'shared/transfer_button_public',
        locals: { transfer: blockchain_transactable }
      )

      broadcast_replace_later_to(
        blockchain_transactable,
        :updates,
        target: "transfer_button_admin_#{blockchain_transactable.id}",
        partial: 'shared/transfer_button_admin',
        locals: { transfer: blockchain_transactable }
      )
    end
  end

  def amounts
    self[:amounts].map(&:to_i)
  end

  def commencement_dates
    self[:commencement_dates].map do |date|
      (date && Time.zone.parse(date)).to_i
    end
  end

  def lockup_schedule_ids
    self[:lockup_schedule_ids].map(&:to_i)
  end

  private

    def on_chain_eth
      if token._token_type_erc20?
        on_chain_erc20
      elsif token._token_type_comakery_security_token?
        on_chain_erc20
      elsif token._token_type_token_release_schedule?
        on_chain_lockup
      else
        Comakery::Eth::Tx.new(token.blockchain.explorer_api_host, tx_hash, self)
      end
    end

    def on_chain_erc20
      case blockchain_transactable.transfer_type.name
      when 'mint'
        Comakery::Eth::Tx::Erc20::Mint.new(token.blockchain.explorer_api_host, tx_hash, self)
      when 'burn'
        Comakery::Eth::Tx::Erc20::Burn.new(token.blockchain.explorer_api_host, tx_hash, self)
      else
        if blockchain_transactables.size > 1 && token.batch_contract_address
          Comakery::Eth::Tx::Erc20::BatchTransfer.new(token.blockchain.explorer_api_host, tx_hash, self)
        else
          Comakery::Eth::Tx::Erc20::Transfer.new(token.blockchain.explorer_api_host, tx_hash, self)
        end
      end
    end

    def on_chain_lockup
      if blockchain_transactables.size > 1
        Comakery::Eth::Tx::Erc20::ScheduledToken::BatchFundReleaseSchedule.new(token.blockchain.explorer_api_host, tx_hash, self)
      else
        Comakery::Eth::Tx::Erc20::ScheduledToken::FundReleaseSchedule.new(token.blockchain.explorer_api_host, tx_hash, self)
      end
    end

    def on_chain_dag
      Comakery::Dag::Tx.new(token.blockchain.explorer_api_host, tx_hash)
    end

    def on_chain_algo
      Comakery::Algorand::Tx.new(self)
    end

    def on_chain_asa
      Comakery::Algorand::Tx::Asset.new(self)
    end

    def on_chain_ast
      case blockchain_transactable.transfer_type.name
      when 'mint'
        on_chain_ast_mint
      when 'burn'
        on_chain_ast_burn
      else
        on_chain_ast_transfer
      end
    end

    def on_chain_ast_transfer
      Comakery::Algorand::Tx::App::SecurityToken::Transfer.new(self)
    end

    def on_chain_ast_burn
      Comakery::Algorand::Tx::App::SecurityToken::Burn.new(self)
    end

    def on_chain_ast_mint
      Comakery::Algorand::Tx::App::SecurityToken::Mint.new(self)
    end

    def populate_data
      super
      populate_amounts
      populate_destinations
      populate_lockup
    end

    def populate_amounts
      if amounts.empty?
        self.amounts = blockchain_transactables.map do |t|
          token.to_base_unit(t.total_amount)
        end
      end

      self.amount ||= amounts.sum
    end

    def populate_destinations
      self.destinations = blockchain_transactables.map(&:recipient_address) if destinations.empty?
      self.destination ||= destinations.first
    end

    def populate_lockup
      self.commencement_dates = blockchain_transactables.map(&:commencement_date) if commencement_dates.empty?
      self.lockup_schedule_ids = blockchain_transactables.map(&:lockup_schedule_id) if lockup_schedule_ids.empty?
    end
end
