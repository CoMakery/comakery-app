require 'rails_helper'

describe AccountTokenRecord do
  describe 'associations' do
    let!(:token) { create(:token, coin_type: :comakery) }
    let!(:reg_group) { create(:reg_group, token: token) }
    let!(:account) { create(:account) }
    let!(:account_token_record) { create(:account_token_record, token: token, reg_group: reg_group, account: account) }

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

  describe 'validations' do
    it 'requires comakery token' do
      account_token_record = create(:account_token_record)
      account_token_record.token = create(:token)
      expect(account_token_record).not_to be_valid
    end

    it 'requires account to be unique per token' do
      account_token_record = create(:account_token_record)
      create(:account_token_record, account: account_token_record.account)
      account_token_record2 = build(:account_token_record, token: account_token_record.token, account: account_token_record.account)

      expect(account_token_record2).not_to be_valid
    end
  end
end
