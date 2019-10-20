require 'rails_helper'

describe RegGroup do
  describe 'associations' do
    let!(:token) { create(:token, coin_type: :comakery) }
    let!(:reg_group) { create(:reg_group, token: token) }
    let!(:account_token_record) { create(:account_token_record, token: token, reg_group: reg_group) }
    let!(:sending_transfer_rule) { create(:transfer_rule, token: token, sending_group: reg_group, receiving_group: create(:reg_group, token: token)) }
    let!(:receiving_transfer_rule) { create(:transfer_rule, token: token, receiving_group: reg_group, sending_group: create(:reg_group, token: token)) }

    it 'belongs to token' do
      expect(reg_group.token).to eq(token)
    end

    it 'has many accounts' do
      expect(reg_group.accounts).to match_array([account_token_record.account])
    end

    it 'has many sending_transfer_rules' do
      expect(reg_group.sending_transfer_rules).to match_array([sending_transfer_rule])
    end

    it 'has many receiving_transfer_rules' do
      expect(reg_group.receiving_transfer_rules).to match_array([receiving_transfer_rule])
    end
  end

  describe 'validations' do
    it 'requires comakery token' do
      reg_group = create(:reg_group)
      reg_group.token = create(:token)
      expect(reg_group).not_to be_valid
    end

    it 'requires name to be present' do
      reg_group = create(:reg_group)
      reg_group.name = nil
      expect(reg_group).not_to be_valid
    end

    it 'requires name to be unique per token' do
      reg_group = create(:reg_group)
      create(:reg_group, name: reg_group.name)
      reg_group2 = build(:reg_group, token: reg_group.token, name: reg_group.name)

      expect(reg_group2).not_to be_valid
    end
  end
end
