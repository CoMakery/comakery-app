require 'rails_helper'

describe Comakery::ChartColors do
  describe 'lookup' do
    it 'returns color by index' do
      expect(described_class.lookup(0)).to eq(described_class.array[0])
    end

    context 'when index is larger than number of colors' do
      it 'reduces index' do
        expect(described_class.lookup(100)).to eq(described_class.array[4])
      end
    end
  end
end
