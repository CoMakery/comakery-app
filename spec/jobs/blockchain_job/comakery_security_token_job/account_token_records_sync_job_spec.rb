require 'rails_helper'

RSpec.describe BlockchainJob::ComakerySecurityTokenJob::AccountTokenRecordsSyncJob, type: :job, vcr: true do
  let(:token) { create(:comakery_token) }
  subject { described_class.perform_now(token) }

  context 'with wallets' do
    let!(:wallet) { create(:wallet, _blockchain: token._blockchain, address: '0x8599D17Ac1cEc71CA30264DdFAaca83C334f8451') }

    it 'creates account token records' do
      expect { subject }.to change(token.account_token_records, :count).by(1)

      expect(token.account_token_records.synced.where(
               wallet: wallet,
               account: wallet.account,
               lockup_until: 1590105600,
               max_balance: 500000,
               reg_group: RegGroup.find_by(token: token, blockchain_id: 0),
               account_frozen: false
             )).not_to be_empty
    end

    it 'creates balances' do
      expect { subject }.to change(wallet.balances, :count).by(1)

      expect(wallet.balances.where(
               token: token,
               base_unit_value: 900523
             )).not_to be_empty
    end
  end
end
