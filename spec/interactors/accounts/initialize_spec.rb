require 'rails_helper'

describe Accounts::Initialize do
  describe '#call' do
    context 'when the whitelabel mission is present' do
      let!(:whitelabel_mission) { create(:whitelabel_mission) }
      let!(:account_params) { { email: 'example@gmail.com', password: 'password', agreed_to_user_agreement: '1' } }

      subject(:result) do
        described_class.call(whitelabel_mission: whitelabel_mission, account_params: account_params)
      end

      it 'initialize whitelabel account' do
        expect { result }.not_to change(Account, :count)

        expect(result.account.managed_mission).to be_present
      end
    end

    context 'when the whitelabel mission is nil' do
      let!(:account_params) { { email: 'example@gmail.com', password: 'password', agreed_to_user_agreement: '1' } }

      subject(:result) do
        described_class.call(whitelabel_mission: nil, account_params: account_params)
      end

      it 'initialize an account' do
        expect { result }.not_to change(Account, :count)

        expect(result.account.managed_mission).not_to be_present
      end
    end
  end
end
