require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Eth do
  it_behaves_like 'a token type'

  let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', blockchain: Blockchain::EthereumRopsten.new } }

  specify { expect(described_class.new(**attrs).name).to eq('ETH') }
  specify { expect(described_class.new(**attrs).symbol).to eq('ETH') }
  specify { expect(described_class.new(**attrs).decimals).to eq(18) }
  specify { expect(described_class.new(**attrs).wallet_logo).to eq('OREID_Logo_Symbol.svg') }
  specify { expect(described_class.new(**attrs).contract).to be_a(Comakery::Eth) }
  specify { expect(described_class.new(**attrs).abi).to eq({}) }
  specify { expect(described_class.new(**attrs).tx).to eq(Comakery::Eth::Tx) }
  specify { expect(described_class.new(**attrs).operates_with_smart_contracts?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_account_records?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_reg_groups?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_transfer_rules?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_mint?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_burn?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_freeze?).to be_falsey }

  describe '#blockchain_balance' do
    let(:token_type) { described_class.new(**attrs) }
    subject { token_type.blockchain_balance('dummy_wallet_address') }

    it 'gets balance from a contract' do
      expect_any_instance_of(Comakery::Eth).to receive(:account_balance).with('dummy_wallet_address').and_return(999)

      is_expected.to eq 999
    end
  end
end
