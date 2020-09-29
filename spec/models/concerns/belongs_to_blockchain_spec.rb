shared_examples 'belongs_to_blockchain' do |attrs|
  it { is_expected.to validate_presence_of(:_blockchain) }
  it { is_expected.to define_enum_for(:_blockchain).with_values(Blockchain.list).with_prefix(:_blockchain) }

  describe '.blockchain_for' do
    it 'returns a Blockchain instance for provided name' do
      expect(described_class.blockchain_for('bitcoin')).to be_a(Blockchain::Bitcoin)
    end
  end

  describe '#blockchain' do
    it 'returns a Blockchain instance' do
      expect(described_class.new.blockchain).to be_a(Blockchain::Bitcoin)
    end
  end

  describe '#blockchain_name_for_wallet' do
    it 'returns a Blockchain name suitable for wallet columns on account model' do
      expect(described_class.new.blockchain_name_for_wallet).to eq('bitcoin')
    end
  end

  attrs && attrs[:blockchain_addressable_columns]&.each do |column|
    it "validates :#{column} according Blockchain" do
      obj = described_class.new(column => '0x')
      expect(obj.blockchain).to receive(:validate_addr).with('0x').and_call_original
      expect(obj.valid?).to be_falsey
      expect(obj.errors.details.keys).to include(column)
    end
  end
end
