class Comakery::Algorand::Tx::App::SecurityToken::TransferRestrictions < Comakery::Algorand::Tx::App
  def app_args
    [
      'transfer restrictions',
      (blockchain_transaction.blockchain_transactable.account_frozen ? '1' : '0'),
      blockchain_transaction.blockchain_transactable.max_balance.to_s,
      blockchain_transaction.blockchain_transactable.lockup_until.to_i.to_s,
      blockchain_transaction.blockchain_transactable.reg_group.blockchain_id.to_s
    ]
  end

  def app_accounts
    [
      blockchain_transaction.blockchain_transactable.account.address_for_blockchain(blockchain_transaction.token._blockchain)
    ]
  end
end
