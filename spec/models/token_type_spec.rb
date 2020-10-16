shared_examples 'a token type' do
  describe described_class.new do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:symbol) }
    it { is_expected.to respond_to(:decimals) }
    it { is_expected.to respond_to(:wallet_logo) }
    it { is_expected.to respond_to(:contract) }
    it { is_expected.to respond_to(:abi) }
    it { is_expected.to respond_to(:tx) }
    it { is_expected.to respond_to(:operates_with_smart_contracts?) }
    it { is_expected.to respond_to(:operates_with_account_records?) }
    it { is_expected.to respond_to(:operates_with_reg_groups?) }
    it { is_expected.to respond_to(:operates_with_transfer_rules?) }
    it { is_expected.to respond_to(:supports_token_mint?) }
    it { is_expected.to respond_to(:supports_token_burn?) }
    it { is_expected.to respond_to(:supports_token_freeze?) }
  end
end
