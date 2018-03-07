require 'rails_helper'

RSpec.describe AuthenticationTeam, type: :model do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Authentication can't be blank",
                                  "Provider team can't be blank",
                                ])
    end
  end
end
