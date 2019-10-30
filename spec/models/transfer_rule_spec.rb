require 'rails_helper'

describe TransferRule do
  describe 'associations' do
    let!(:token) { create(:token, coin_type: :comakery) }
    let!(:sending_group) { create(:reg_group, token: token) }
    let!(:receiving_group) { create(:reg_group, token: token) }
    let!(:transfer_rule) { create(:transfer_rule, token: token, sending_group: sending_group, receiving_group: receiving_group) }

    it 'belongs to token' do
      expect(transfer_rule.token).to eq(token)
    end

    it 'belongs to sending_group' do
      expect(transfer_rule.sending_group).to eq(sending_group)
    end

    it 'belongs to receiving_group' do
      expect(transfer_rule.receiving_group).to eq(receiving_group)
    end
  end

  describe 'validations' do
    it 'requires comakery token' do
      transfer_rule = create(:transfer_rule)
      transfer_rule.token = create(:token)
      expect(transfer_rule).not_to be_valid
    end

    it 'requires sending_group and receiving_group combination to be unique' do
      transfer_rule1 = create(:transfer_rule)
      create(:transfer_rule, sending_group: create(:reg_group, token: transfer_rule1.token), receiving_group: transfer_rule1.receiving_group, token: transfer_rule1.token)
      create(:transfer_rule, receiving_group: create(:reg_group, token: transfer_rule1.token), sending_group: transfer_rule1.sending_group, token: transfer_rule1.token)
      transfer_rule4 = build(:transfer_rule, sending_group: transfer_rule1.sending_group, receiving_group: transfer_rule1.receiving_group, token: transfer_rule1.token)

      expect(transfer_rule4).not_to be_valid
    end

    it 'requires sending_group to belong to same token' do
      sending_group = create(:reg_group)
      transfer_rule = build(:transfer_rule, sending_group: sending_group)
      expect(transfer_rule).not_to be_valid
    end

    it 'requires receiving_group to belong to same token' do
      receiving_group = create(:reg_group)
      transfer_rule = build(:transfer_rule, receiving_group: receiving_group)
      expect(transfer_rule).not_to be_valid
    end
  end
end
