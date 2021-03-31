require 'rails_helper'

describe Accounts::Authenticate do
  describe '#call' do
    let!(:email) { 'example@gmail.com' }
    let!(:password) { 'password' }
    let!(:params) { { email: email, password: password } }

    let!(:account) { create(:account, email: email, password: password) }

    subject(:result) do
      described_class.call(whitelabel_mission: nil, email: email, password: password)
    end

    it 'should authenticate account' do
      expect(result.success?).to eq(true)
    end

    context 'when the whitelabel mission is present' do
      let!(:whitelabel_mission) { create(:whitelabel_mission) }
      let!(:account) do
        create(:account, managed_mission: whitelabel_mission,
                         email: email,
                         password: password)
      end

      subject(:result) do
        described_class.call(whitelabel_mission: whitelabel_mission, email: email, password: password)
      end

      it 'returns true' do
        expect(result.success?).to eq(true)
      end
    end

    context 'when data is invalid' do
      subject(:result) do
        described_class.call(whitelabel_mission: nil, email: email, password: '')
      end

      it 'returns false' do
        expect(result.failure?).to eq(true)
        expect(result.account).to eq(nil)
      end
    end
  end
end
