shared_examples 'belongs_to_blockchain' do |attrs|
  it { is_expected.to validate_presence_of(:_blockchain).with_message('unknown blockchain value') }
  it { is_expected.to validate_inclusion_of(:_blockchain).in_array(Blockchain.list.keys.map(&:to_s)).with_message('unknown blockchain value') }
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

  describe '#tokens_of_the_blockchain' do
    it 'returns list of tokens which use the same Blockchain' do
      expect(described_class.new.tokens_of_the_blockchain).to eq(Token.where(_blockchain: described_class.new._blockchain))
    end
  end

  describe '#coin_of_the_blockchain' do
    it 'returns coin token which use the same Blockchain' do
      expect(described_class.new.coin_of_the_blockchain).to eq(Token.where(_blockchain: described_class.new._blockchain).reject { |t| t.token_type.operates_with_smart_contracts? }.first)
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
