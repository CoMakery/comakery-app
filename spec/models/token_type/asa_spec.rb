require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Asa do
  it_behaves_like 'a token type'

  describe 'have filled values' do
    let(:attrs) { { contract_address: '13076367', blockchain: Blockchain::AlgorandTest.new } }
    around(:each) do |example|
      VCR.use_cassette("algorand/AlgorandTest/#{attrs[:contract_address]}/asset_data") do
        example.run
      end
    end
    subject { described_class.new(**attrs) }

    specify { expect(subject.name).to eq('ASA') }
    specify { expect(subject.symbol).to eq('CMKTEST') }
    specify { expect(subject.decimals).to eq(2) }
    specify { expect(subject.wallet_logo).to eq 'OREID_Logo_Symbol.svg' }
    specify { expect(subject.contract).to be_a(Comakery::Algorand) }
    specify { expect(subject.abi).to eq({}) }
    specify { expect(subject.tx).to be_nil }
    specify { expect(subject.operates_with_smart_contracts?).to be true }
    specify { expect(subject.operates_with_account_records?).to be_falsey }
    specify { expect(subject.operates_with_reg_groups?).to be_falsey }
    specify { expect(subject.operates_with_transfer_rules?).to be_falsey }
    specify { expect(subject.supports_token_mint?).to be_falsey }
    specify { expect(subject.supports_token_burn?).to be_falsey }
    specify { expect(subject.supports_token_freeze?).to be_falsey }
  end
end
