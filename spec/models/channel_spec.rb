require 'rails_helper'

RSpec.describe Channel, type: :model do
  describe '#validations' do
    it 'requires many attributes' do
      channel = described_class.new
      expect(channel).not_to be_valid
      expect(channel.errors.full_messages).to eq(["Name can't be blank", "Team can't be blank", "Project can't be blank"])
    end
  end
end
