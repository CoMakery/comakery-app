require 'rails_helper'

describe Mission do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Description can't be blank",
                                  "Image can't be blank",
                                  "Logo can't be blank",
                                  "Name can't be blank",
                                  "Subtitle can't be blank"
                                ])
    end

    it 'raises error if the attribute is too long' do
      errors = described_class.new(name: 'a' * 101, subtitle: 'a' * 141, description: 'a' * 376).tap(&:valid?).errors.full_messages
      expect(errors).to include('Name is too long (maximum is 100 characters)')
      expect(errors).to include('Subtitle is too long (maximum is 140 characters)')
      expect(errors).to include('Description is too long (maximum is 375 characters)')
    end
  end
end
