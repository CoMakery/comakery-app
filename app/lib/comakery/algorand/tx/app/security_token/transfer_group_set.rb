class Comakery::Algorand::Tx::App::SecurityToken::TransferGroupSet < Comakery::Algorand::Tx::App
  def app_args
    [
      'transfer group',
      'set',
      blockchain_transaction.blockchain_transactable.reg_group.blockchain_id.to_s
    ]
  end

  def app_accounts
    [
      blockchain_transaction.blockchain_transactable.account.address_for_blockchain(blockchain_transaction.token._blockchain)
    ]
  end
end
