require 'rails_helper'

describe Comakery::CSV do
  describe 'generate_multiplatform' do
    it 'generates tab delimeted CSV file in utf-16le encoding' do
      csv = described_class.generate_multiplatform do |c|
        c << ['Вода', 'Water', '💧']
      end
      expect(csv.encoding.to_s).to eq 'UTF-16LE'
      expect(csv.bytes[0..1]).to eq [255, 254]
      expect(CSV.parse(csv, col_sep: "\t", encoding: 'utf-16le')).to eq([["\uFEFF\u0412\u043E\u0434\u0430", 'Water', "\u{1F4A7}"]].map { |row| row.map { |cell| cell.encode 'utf-16le' } })
    end
  end
end
