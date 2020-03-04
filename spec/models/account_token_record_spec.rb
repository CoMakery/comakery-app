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

  describe 'callbacks' do
    it 'sets default values' do
      account_token_record = described_class.new

      expect(account_token_record.lockup_until).not_to be_nil
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

  describe 'lockup_until' do
    let!(:account_token_record) { create(:account_token_record) }
    let!(:max_uint256) { 115792089237316195423570985008687907853269984665640564039458 }

    it 'stores Time as a high precision decimal (which able to fit uint256) and returns Time object initialized from decimal' do
      account_token_record.lockup_until = Time.zone.at(max_uint256)
      account_token_record.save!

      expect(account_token_record.reload.lockup_until).to eq(Time.zone.at(max_uint256))
    end
  end
end
