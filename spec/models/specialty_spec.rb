require 'rails_helper'

describe Specialty do
  it { is_expected.to have_many(:accounts) }
  it { is_expected.to have_many(:interests) }
  it { is_expected.to have_many(:award_types) }

  describe '#initializer_setup' do
    before do
      described_class.initializer_setup
    end

    it 'initializer has autopopulated the specialties' do
      expect(described_class.find(1).name).to eq('Audio Or Video Production')
    end

    it 'only creates the values once' do
      starting_count = described_class.count
      expect(starting_count).to be_positive
      described_class.initializer_setup
      described_class.initializer_setup
      expect(described_class.count).to eq(starting_count)
    end
  end

  describe '.default' do
    it 'returns General specialty' do
      expect(described_class.default.name).to eq('General')
    end
  end

  it 'must have a unique name' do
    described_class.create(name: 'Golf')
    specialty = described_class.new(name: 'Golf')
    specialty.valid?
    expect(specialty.errors[:name]).to eq(['has already been taken'])
  end
end
