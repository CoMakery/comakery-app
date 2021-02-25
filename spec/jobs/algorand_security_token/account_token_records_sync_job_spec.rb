require 'rails_helper'

RSpec.describe AlgorandSecurityToken::AccountTokenRecordsSyncJob, type: :job, vcr: true do
  let(:token) { create(:algo_sec_token, contract_address: '13997710') }
  subject { described_class.perform_now(token) }

  context 'with opted in wallets' do
    let!(:wallet) { create(:wallet, _blockchain: :algorand_test, address: 'QLL4PEGFO7MGQJGUOPUT3MANOI2U3TG5YF3ZM66FPF4GMORTIKPHOYIGSI') }
    let!(:opt_in) { create(:token_opt_in, wallet: wallet, token: token, status: :opted_in) }

    it 'creates account token records' do
      expect { subject }.to change(token.account_token_records, :count).by(1)

      expect(token.account_token_records.synced.where(
               wallet: wallet,
               account: wallet.account,
               lockup_until: 1614299570,
               max_balance: 22000000000,
               reg_group: RegGroup.find_by(token: token, blockchain_id: 1),
               account_frozen: false
             )).not_to be_empty
    end

    it 'creates balances' do
      expect { subject }.to change(wallet.balances, :count).by(1)

      expect(wallet.balances.where(
               token: token,
               base_unit_value: 106250051
             )).not_to be_empty
    end
  end
end
