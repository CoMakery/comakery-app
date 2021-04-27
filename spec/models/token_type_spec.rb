require 'rails_helper'

describe TokenType, type: :model do
  subject { described_class }

  specify { expect(subject.list).to be_a(Hash) }
  specify { expect(subject.append_to_list(nil)).to be_a(Hash) }
  specify { expect(subject.all).to be_an(Array) }
  specify { expect(subject.with_balance_support).to include(TokenType::Erc20) }
  specify { expect(subject.with_balance_support).not_to include(TokenType::Btc) }
end

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
    it { is_expected.to respond_to(:supports_balance?) }
    it { is_expected.to respond_to(:blockchain_balance) }
  end
end
