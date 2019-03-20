require 'rails_helper'

describe Specialty do
  describe '#initializer_setup' do
    before do
      Specialty.initializer_setup
    end

    it 'initializer has autopopulated the specialties' do
      expect(Specialty.find(1).name).to eq("Audio Or Video Production")
    end

    it 'only creates the values once' do
      starting_count = Specialty.count
      expect(starting_count).to be > 0
      Specialty.initializer_setup
      Specialty.initializer_setup
      expect(Specialty.count).to eq(starting_count)
    end
  end

  it 'must have a unique name' do
    Specialty.create(name: 'Golf')
    specialty = Specialty.new(name: 'Golf')
    specialty.valid?
    expect(specialty.errors[:name]).to eq(['has already been taken'])
  end
end