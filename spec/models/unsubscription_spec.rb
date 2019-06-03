require 'rails_helper'

RSpec.describe Unsubscription, type: :model do
  describe 'validations' do
    let!(:record_without_email) { described_class.new }
    let!(:record) { described_class.create(email: 'test') }

    it 'must have an email' do
      expect(record_without_email.valid?).to be false
    end

    it 'must have unique email' do
      unsub = described_class.new(email: record.email)
      expect(unsub.valid?).to be false
      expect(unsub.errors[:email]).to eq(['Is Already Unsubscribed'])
    end
  end
end
