require 'rails_helper'

describe MissionPolicy do
  subject(:policy) { described_class.new(account, nil) }

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
