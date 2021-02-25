class Comakery::Algorand::Tx::App::SecurityToken::SetAddressPermissions < Comakery::Algorand::Tx::App
  def app_args
    [
      'setAddressPermissions',
      (blockchain_transaction.blockchain_transactable.account_frozen ? 1 : 0),
      blockchain_transaction.blockchain_transactable.max_balance,
      blockchain_transaction.blockchain_transactable.lockup_until.to_i,
      blockchain_transaction.blockchain_transactable.reg_group.blockchain_id
    ]
  end

  def app_accounts
    [
      blockchain_transaction.destination
    ]
  end
end
