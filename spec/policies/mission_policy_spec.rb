require 'rails_helper'

describe MissionPolicy do
  subject(:policy) { described_class.new(account, nil) }

  let!(:token) { create :token }
  let!(:mission) { create :mission, token_id: token.id }
  let!(:mission2) { create :mission, name: '2', token_id: token.id }
  let!(:mission3) { create :mission, name: '3', token_id: token.id }
  let!(:account) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }

  describe MissionPolicy::Scope do
    describe '#resolve' do
      it 'returns all missions with admin flag' do
        expect(MissionPolicy::Scope.new(admin_account, Mission).resolve.count).to eq 3
      end

      it 'returns no missions without admin flag' do
        expect(MissionPolicy::Scope.new(nil, Mission).resolve&.count).to eq 0
        expect(MissionPolicy::Scope.new(account, Mission).resolve&.count).to eq 0
      end
    end
  end

  context 'for an admin account' do
    let(:account) { create :account, comakery_admin: true }

    it { expect(policy.new?).to be true }
    it { expect(policy.edit?).to be true }
    it { expect(policy.index?).to be true }
    it { expect(policy.create?).to be true }
    it { expect(policy.update?).to be true }
    it { expect(policy.destroy?).to be true }
  end

  context 'for a non-admin account' do
    let(:account) { create :account, comakery_admin: false }

    it { expect(policy.new?).to be false }
    it { expect(policy.edit?).to be false }
    it { expect(policy.index?).to be false }
    it { expect(policy.create?).to be false }
    it { expect(policy.update?).to be false }
    it { expect(policy.destroy?).to be false }
  end
end
