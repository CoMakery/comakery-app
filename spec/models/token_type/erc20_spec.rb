require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Erc20, vcr: true do
  it_behaves_like 'a token type'

  let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', blockchain: Blockchain::EthereumRopsten.new } }

  specify { expect(described_class.new(**attrs).name).to eq('ERC20') }
  specify { expect(described_class.new(**attrs).symbol).to eq('BOKKY') }
  specify { expect(described_class.new(**attrs).decimals).to eq(18) }
  specify { expect(described_class.new(**attrs).wallet_logo).to eq('wallet-connect-logo.svg') }
  specify { expect(described_class.new(**attrs).contract).to be_a(Comakery::Eth::Contract::Erc20) }
  specify { expect(described_class.new(**attrs).abi).to be_an(Array) }
  specify { expect(described_class.new(**attrs).batch_abi).to be_an(Array) }
  specify { expect(described_class.new(**attrs).tx).to be_nil }
  specify { expect(described_class.new(**attrs).operates_with_smart_contracts?).to be_truthy }
  specify { expect(described_class.new(**attrs).operates_with_account_records?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_reg_groups?).to be_falsey }
  specify { expect(described_class.new(**attrs).operates_with_transfer_rules?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_mint?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_burn?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_token_freeze?).to be_falsey }
  specify { expect(described_class.new(**attrs).supports_balance?).to be_truthy }

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

    describe '#blockchain_balance' do
      let(:token_type) { described_class.new(**attrs) }
      subject { token_type.blockchain_balance(build(:ethereum_address_1)) }

      it 'gets balance from a contract' do
        # Get it using VCR from blockchain
        is_expected.to eq 0
      end
    end
  end

  describe 'human url' do
    let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', blockchain: Blockchain::EthereumRopsten.new } }

    subject { described_class.new(**attrs) }

    specify { expect(subject.human_url).to eq 'https://ropsten.etherscan.io/address/0x583cbbb8a8443b38abcc0c956bece47340ea1367' }
    specify { expect(subject.human_url_name).to eq '0x583cbbb8a8443b38abcc0c956bece47340ea1367' }
  end
end
