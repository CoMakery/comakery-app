require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Xtz do
  it_behaves_like 'a token type'

  specify { expect(described_class.new.name).to eq('XTZ') }
  specify { expect(described_class.new.symbol).to eq('XTZ') }
  specify { expect(described_class.new.decimals).to eq(6) }
  specify { expect(described_class.new.wallet_logo).to eq('tezos.png') }
  specify { expect(described_class.new.contract).to be_nil }
  specify { expect(described_class.new.abi).to eq({}) }
  specify { expect(described_class.new.tx).to be_nil }
  specify { expect(described_class.new.operates_with_smart_contracts?).to be_falsey }
  specify { expect(described_class.new.operates_with_account_records?).to be_falsey }
  specify { expect(described_class.new.operates_with_reg_groups?).to be_falsey }
  specify { expect(described_class.new.operates_with_transfer_rules?).to be_falsey }
  specify { expect(described_class.new.supports_token_mint?).to be_falsey }
  specify { expect(described_class.new.supports_token_burn?).to be_falsey }
  specify { expect(described_class.new.supports_token_freeze?).to be_falsey }
  specify { expect(described_class.new.supports_balance?).to be_falsey }

  describe '#blockchain_balance' do
    subject { described_class.new.blockchain_balance('dummy_wallet_address') }

    it do
      expect { subject }.to raise_error NotImplementedError
    end
  end

  describe 'human url' do
    let(:attrs) { { contract_address: nil, blockchain: Blockchain::Tezos.new } }

    subject { described_class.new(**attrs) }

    specify { expect(subject.human_url).to eq 'https://tzscan.io/' }
    specify { expect(subject.human_url_name).to eq 'XTZ' }
  end
end
