class Comakery::Algorand::Tx::App::SecurityToken::Freeze < Comakery::Algorand::Tx::App
  def app_args
    %w[
      freeze
      1
    ]
  end

  def app_accounts
    [
      blockchain_transaction.blockchain_transactable.account.address_for_blockchain(blockchain_transaction.token._blockchain)
    ]
  end
end
