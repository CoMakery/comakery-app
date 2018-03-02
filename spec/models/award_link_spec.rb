require 'rails_helper'

describe AwardLink do
  describe 'validations' do
    it 'requires things be present' do
      expect(described_class.new(quantity: nil).tap(&:valid?).errors.full_messages)
        .to match_array([
                          "Award type can't be blank",
                          "Quantity can't be blank"
                        ])
    end
  end
end
