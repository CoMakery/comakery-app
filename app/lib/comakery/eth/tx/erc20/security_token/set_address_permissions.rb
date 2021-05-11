class Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions < Comakery::Eth::Tx::Erc20
  def method_name
    'setAddressPermissions'
  end

  def method_params
    [
      blockchain_transaction.destination,
      blockchain_transaction.blockchain_transactable.reg_group.blockchain_id,
      blockchain_transaction.blockchain_transactable.lockup_until.to_i,
      blockchain_transaction.blockchain_transactable.max_balance,
      blockchain_transaction.blockchain_transactable.account_frozen
    ]
  end
end
