require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Erc20, vcr: true do
  it_behaves_like 'a token type'

  let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', blockchain: Blockchain::EthereumRopsten.new } }

  specify { expect(described_class.new(**attrs).name).to eq('ERC20') }
  specify { expect(described_class.new(**attrs).symbol).to eq('BOKKY') }
  specify { expect(described_class.new(**attrs).decimals).to eq(18) }
  specify { expect(described_class.new(**attrs).contract).to be_a(Comakery::Eth::Contract::Erc20) }
  specify { expect(described_class.new(**attrs).abi).to be_an(Array) }
  specify { expect(described_class.new(**attrs).tx).to be_nil }
  specify { expect(described_class.new(**attrs).operates_with_smart_contracts?).to be_truthy }
  specify { expect(described_class.new(**attrs).operates_with_account_records?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_reg_groups?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_transfer_rules?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_mint?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_burn?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_freeze?).to be_falsey }

  describe 'contract' do
    context 'when contract_address is invalid' do
      let(:attrs) { { contract_address: '0x', blockchain: Blockchain::EthereumRopsten.new } }

      it 'raises an error' do
        expect { described_class.new(**attrs).contract }.to raise_error(TokenType::Contract::ValidationError)
      end
    end

    context 'when contract_address doesnt exist on network' do
      let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1368', blockchain: Blockchain::EthereumRopsten.new } }

      it 'raises an error' do
        expect { described_class.new(**attrs).contract }.to raise_error(TokenType::Contract::ValidationError)
      end
    end
  end
end
