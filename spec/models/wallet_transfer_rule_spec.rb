require 'rails_helper'

describe WalletTransferRule do
  describe 'associations' do
    let(:token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
    let(:reg_group) { create(:reg_group, token: token) }
    let(:account) { create(:account) }
    let(:wallet) { create(:wallet, address: build(:ethereum_contract_address), account: account, _blockchain: token._blockchain) }
    let(:account_token_record) { create(:account_token_record, token: token, reg_group: reg_group, account: account, wallet: wallet) }

    it 'belongs to token' do
      expect(account_token_record.token).to eq(token)
    end

    it 'belongs to account' do
      expect(account_token_record.account).to eq(account)
    end

    it 'belongs to reg_group' do
      expect(account_token_record.reg_group).to eq(reg_group)
    end
  end
end
