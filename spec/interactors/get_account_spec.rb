require 'rails_helper'

describe GetAccount do
  describe '#call' do
    let!(:project) { create(:project) }
    let!(:account) { create(:account) }

    context 'when whitelabel mission is present' do
      let!(:whitelabel_mission) { create(:whitelabel_mission) }

      before { account.update(managed_mission: whitelabel_mission) }

      subject(:result) do
        described_class.call(whitelabel_mission: whitelabel_mission, email: Faker::Internet.email)
      end

      it { expect(result.success?).to be(true) }
    end

    context 'when whitelabel mission is nil' do
      subject(:result) do
        described_class.call(whitelabel_mission: nil, email: Faker::Internet.email)
      end

      it { expect(result.success?).to be(true) }
    end
  end
end
