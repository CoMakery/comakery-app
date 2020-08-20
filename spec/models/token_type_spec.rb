shared_examples 'a token type' do
  describe described_class.new do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:symbol) }
    it { is_expected.to respond_to(:decimals) }
    it { is_expected.to respond_to(:contract) }
    it { is_expected.to respond_to(:tx) }
  end
end
