require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Qrc20, vcr: true do
  it_behaves_like 'a token type'

  let(:attrs) { { contract_address: '8cfe9e9893e4386645eae8107cd53aaccf96b7fd', blockchain: Blockchain::QtumTest.new } }

  specify { expect(described_class.new(**attrs).name).to eq('QRC20') }
  specify { expect(described_class.new(**attrs).symbol).to eq('INK') }
  specify { expect(described_class.new(**attrs).decimals).to be_nil }
  specify { expect(described_class.new(**attrs).wallet_logo).to eq('qrypto.png') }
  specify { expect(described_class.new(**attrs).contract).to be_a(Comakery::Qtum::Contract::Qrc20) }
  specify { expect(described_class.new(**attrs).abi).to eq({}) }
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
      let(:attrs) { { contract_address: '8cfe', blockchain: Blockchain::QtumTest.new } }

      it 'raises an error' do
        expect { described_class.new(**attrs).contract }.to raise_error(TokenType::Contract::ValidationError)
      end
    end

    context 'when contract_address doesnt exist on network' do
      let(:attrs) { { contract_address: '8cfe9e9893e4386645eae8107cd53aaccf96b7fe', blockchain: Blockchain::QtumTest.new } }

      it 'raises an error' do
        expect { described_class.new(**attrs).contract }.to raise_error(TokenType::Contract::ValidationError)
      end
    end
  end
end
