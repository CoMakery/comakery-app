require 'rails_helper'

describe BetaSignup do
  describe 'validations' do
    it 'requires an email address' do
      expect(described_class.new.tap(&:valid?).errors.full_messages).to eq(["Email address can't be blank"])
      expect(described_class.new(email_address: 'somethign not an email').tap(&:valid?).errors.full_messages).to eq(['Email address is invalid'])
    end
  end
end
