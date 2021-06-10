require 'rails_helper'

describe SendInvite, skip: true do
  describe '#call' do
    context 'account registered' do
      let!(:project) { create(:project) }
      let!(:account) { create(:account) }
      let!(:params) { { email: account.email, role: :interested } }

      context 'when whitelabel mission is present' do
        let!(:whitelabel_mission) { create(:whitelabel_mission) }

        before { account.update(managed_mission: whitelabel_mission) }

        subject(:result) do
          described_class.call(project: project, whitelabel_mission: whitelabel_mission, params: params)
        end

        it { expect(result.success?).to be(true) }

        it { expect { result }.to change(ProjectRole, :count).by(1) }
      end

      context 'when whitelabel mission is nil' do
        subject(:result) do
          described_class.call(project: project, params: params)
        end

        it { expect(result.success?).to be(true) }

        it { expect { result }.to change(ProjectRole, :count).by(1) }
      end
    end

    context 'account doesn\'t exist' do
      let!(:project) { create(:project) }
      let!(:account) { create(:account) }
      let!(:params) { { email: 'unregistered@gmail.com', role: :interested } }

      subject(:result) do
        described_class.call(project: project, params: params)
      end

      it { expect(result.success?).to be(false) }

      it { expect(result.errors).to eq(['The user must have signed up to add them']) }

      it { expect { result }.not_to change(ProjectRole, :count) }
    end
  end
end
