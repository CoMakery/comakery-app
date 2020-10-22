require 'rails_helper'

describe TokenPolicy do
  let!(:token) { create :token }
  let!(:token2) { create :token, name: '2' }
  let!(:token3) { create :token, name: '3' }
  let!(:account) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }

  describe TokenPolicy::Scope do
    describe '#resolve' do
      it 'returns all tokens with admin flag' do
        expect(TokenPolicy::Scope.new(admin_account, Token).resolve.count).to eq 3
      end

      it 'returns no tokens without admin flag' do
        expect(TokenPolicy::Scope.new(nil, Token).resolve&.count).to eq 0
        expect(TokenPolicy::Scope.new(account, Token).resolve&.count).to eq 0
      end
    end
  end

  describe '#new? and #create? and #index? and #show? and #edit? and #update? and #fetch_contract_details?' do
    it 'allow any action to proceed only with admin flag' do
      %i[new? create? index? show? edit? update? fetch_contract_details?].each do |action|
        expect(described_class.new(nil, token).send(action)).to be_falsey
        expect(described_class.new(account, token).send(action)).to be_falsey
        expect(described_class.new(admin_account, token).send(action)).to be true
      end
    end
  end

  describe '#refresh_transfer_rules_enabled?' do
    let(:account) { create(:account) }
    let!(:token) { create(:token, _token_type: :comakery_security_token, symbol: 'TEST', contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37', decimal_places: 1) }

    specify 'no transfer rules' do
      expect(described_class.new(account, token).refresh_transfer_rules_enabled?).to be true
    end

    specify 'transfer rule synced more than 10 minutes ago' do
      create(:transfer_rule, token: token, status: 'synced', synced_at: 11.minutes.ago)

      expect(described_class.new(account, token).refresh_transfer_rules_enabled?).to be true
    end

    specify 'transfer rule synced less than 10 minutes ago' do
      create(:transfer_rule, token: token, status: 'synced', synced_at: 9.minutes.ago)

      expect(described_class.new(account, token).refresh_transfer_rules_enabled?).to be false
    end
  end
end
