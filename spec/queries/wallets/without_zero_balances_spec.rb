require 'rails_helper'

describe Wallets::WithoutZeroBalances do
  describe '.call' do
    let!(:wallet_wo_balance) { create(:wallet) }
    let!(:wallet_with_zero_balance) { create(:wallet) }
    let!(:wallet_with_non_zero_balance) { create(:wallet) }

    let!(:empty_balance) { create(:balance, base_unit_value: 0, wallet: wallet_with_zero_balance) }
    let!(:non_empty_balance) { create(:balance, base_unit_value: 1, wallet: wallet_with_non_zero_balance) }

    it 'returns wallets with non zero balances' do
      wallets = Wallets::WithoutZeroBalances.call
      expect(wallets).to include(wallet_with_non_zero_balance)
      expect(wallets).not_to include(wallet_wo_balance)
      expect(wallets).not_to include(wallet_with_zero_balance)
    end
  end
end
