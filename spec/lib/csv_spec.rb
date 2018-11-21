require 'rails_helper'

describe Comakery::CSV do
  describe 'generate_multiplatform' do
    it 'generates tab delimeted CSV file in utf-16le encoding' do
      csv = described_class.generate_multiplatform do |csv|
        csv << ['Вода', 'Water', '💧']
      end
      expect(csv.encoding.to_s).to eq 'UTF-16LE'
      expect(csv.bytes[0..1]).to eq [255, 254]
      expect(CSV.parse(csv, col_sep: "\t")).to eq [['Вода'.encode('utf-16le').prepend("\xFF\xFE".force_encoding('utf-16le')), 'Water'.encode('utf-16le'), '💧'.encode('utf-16le')]]
    end
  end
end
