require 'rails_helper'

describe Verification do
  describe 'associations' do
    let!(:account) { create(:account) }
    let!(:provider) { create(:account) }
    let!(:verification) { create(:verification, account: account, provider: provider) }

    it 'belongs to account' do
      expect(verification.account).to eq(account)
    end

    it 'belongs to provider' do
      expect(verification.provider).to eq(provider)
    end
  end

  describe 'validations' do
    it 'requires attributes to be present' do
      verification = described_class.new
      expect(verification).not_to be_valid
      expect(verification.errors.full_messages).to eq(['Passed is not boolean', 'Max investment usd is not a number'])
    end

    it 'requires max_investment_usd to be greater than 0' do
      verification = create(:verification)
      verification.max_investment_usd = 0
      expect(verification).not_to be_valid
    end
  end

  describe 'hooks' do
    let!(:verification) { create(:verification) }

    it 'runs set_account_latest_verification after create' do
      expect(verification.account.latest_verification).to eq(verification)
    end
  end
end
