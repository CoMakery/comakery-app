require 'rails_helper'

describe SendInvite do
  describe '#call' do
    context 'account registered' do
      let!(:project) { create(:project) }
      let!(:account) { create(:account, email: 'example@gmail.com') }
      let!(:params) { { email: 'example@gmail.com', role: :member } }

      subject(:result) do
        described_class.call(project: project, params: params)
      end

      it { expect(result.success?).to be(true) }

      it { expect { result }.to change(Interest, :count).by(1) }
    end

    context 'account doesn\'t exist' do
      let!(:project) { create(:project) }
      let!(:account) { create(:account) }
      let!(:params) { { email: 'unregistered@gmail.com', role: :member } }

      subject(:result) do
        described_class.call(project: project, params: params)
      end

      it { expect(result.success?).to be(false) }

      it { expect(result.errors).to eq(['The user must have signed up to add them']) }

      it { expect { result }.not_to change(Interest, :count) }
    end
  end
end
