require 'rails_helper'

describe RegGroup do
  describe 'associations' do
    let!(:token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
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

    it 'requires blockchain_id to be present' do
      reg_group = create(:reg_group)
      reg_group.blockchain_id = nil
      expect(reg_group).not_to be_valid
    end

    it 'requires name to be unique per token' do
      reg_group = create(:reg_group)
      create(:reg_group, name: reg_group.name)
      reg_group2 = build(:reg_group, token: reg_group.token, name: reg_group.name)

      expect(reg_group2).not_to be_valid
    end

    it 'requires blockchain_id to be unique per token' do
      reg_group = create(:reg_group)
      create(:reg_group, blockchain_id: reg_group.blockchain_id)
      reg_group2 = build(:reg_group, token: reg_group.token, blockchain_id: reg_group.blockchain_id)

      expect(reg_group2).not_to be_valid
    end

    it 'requires blockchain_id to be not less than min value' do
      reg_group = build(:reg_group, blockchain_id: described_class::BLOCKCHAIN_ID_MIN - 1)
      expect(reg_group).not_to be_valid
    end

    it 'requires blockchain_id to be not greater than max value' do
      reg_group = build(:reg_group, blockchain_id: described_class::BLOCKCHAIN_ID_MAX + 1)
      expect(reg_group).not_to be_valid
    end

    it 'blockchain_id is readonly' do
      reg_group = build(:reg_group)
      expect(reg_group).to have_readonly_attribute :blockchain_id
    end
  end

  describe 'hooks' do
    context '#set_name' do
      let(:reg_group) { build(:reg_group) }
      let!(:reg_group_w_name) { create(:reg_group, name: 'test') }

      before do
        reg_group.name = nil
        reg_group.save
      end

      it 'runs as before validation' do
        expect(reg_group.name).to eq(reg_group.blockchain_id.to_s)
        expect(reg_group_w_name.name).to eq('test')
      end
    end

    context '#set_blockchain_id' do
      it 'runs after initialization' do
        reg_group = build(:reg_group, blockchain_id: nil)
        expect(reg_group.blockchain_id).to eq 1
      end

      it 'set blockchain_id as next after last existed' do
        token = create(:comakery_dummy_token)
        create(:reg_group, token: token, blockchain_id: 999)
        reg_group = build(:reg_group, blockchain_id: nil, token: token)

        expect(reg_group.blockchain_id).to eq 1000
      end
    end
  end

  describe 'default_for' do
    it 'returns default reg group for token' do
      expect(described_class.default_for(create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten))).to be_a(described_class)
    end
  end
end
