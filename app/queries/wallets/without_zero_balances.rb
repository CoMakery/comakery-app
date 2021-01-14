module Wallets
  class WithoutZeroBalances
    def self.call(relation: Wallet.all)
      relation.left_joins(:balances).where('balances.base_unit_value > 0')
    end
  end
end
