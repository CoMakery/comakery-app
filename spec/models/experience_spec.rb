require 'rails_helper'

describe Experience do
  describe 'associations' do
    let!(:specialty) { create(:specialty) }
    let!(:account) { create(:account) }
    let!(:experience) { create(:experience, specialty: specialty, account: account) }

    it 'belongs to account' do
      expect(experience.account).to eq(account)
    end

    it 'belongs to specialty' do
      expect(experience.specialty).to eq(specialty)
    end
  end

  describe '.increment_for(account, specialty)' do
    let!(:account) { create(:account) }
    let!(:specialty) { create(:specialty) }
    let!(:general_specialty) { Specialty.find_or_create_by(name: 'General') }

    it 'increments experience level for given account and specialty' do
      expect do
        described_class.increment_for(account, specialty)
      end.to change { described_class.find_by(account: account, specialty: specialty)&.level.to_i }.by(1)
    end

    it 'increments General experience level as well, when specialty is not General' do
      expect do
        described_class.increment_for(account, specialty)
      end.to change { described_class.find_by(account: account, specialty: general_specialty)&.level.to_i }.by(1)
    end

    it 'increments General experience level once when specialty is General' do
      expect do
        described_class.increment_for(account, general_specialty)
      end.to change { described_class.find_by(account: account, specialty: general_specialty)&.level.to_i }.by(1)
    end
  end
end
