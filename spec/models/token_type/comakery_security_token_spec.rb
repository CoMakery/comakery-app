require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::ComakerySecurityToken, vcr: true do
  it_behaves_like 'a token type'

  let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', blockchain: Blockchain::EthereumRopsten.new } }

  specify { expect(described_class.new(**attrs).name).to eq('Comakery Security Token') }
  specify { expect(described_class.new(**attrs).abi).to be_an(Array) }
  specify { expect(described_class.new(**attrs).operates_with_smart_contracts?).to be_truthy }
  specify { expect(described_class.new(**attrs).operates_with_account_records?).to be_truthy }
  specify { expect(described_class.new(**attrs).operates_with_reg_groups?).to be_truthy }
  specify { expect(described_class.new(**attrs).operates_with_transfer_rules?).to be_truthy }
  specify { expect(described_class.new(**attrs).supports_token_mint?).to be_truthy }
  specify { expect(described_class.new(**attrs).supports_token_burn?).to be_truthy }
  specify { expect(described_class.new(**attrs).supports_token_freeze?).to be_truthy }
  specify { expect(described_class.new(**attrs).default_reg_group).to eq(0) }
  specify { expect(described_class.new(**attrs).transfer_rule_sync_job).to eq(BlockchainJob::ComakerySecurityTokenJob::TransferRulesSyncJob) }
  specify { expect(described_class.new(**attrs).accounts_sync_job).to eq(BlockchainJob::ComakerySecurityTokenJob::AccountTokenRecordsSyncJob) }

  describe '#blockchain_balance' do
    let(:token_type) { described_class.new(**attrs) }
    subject { token_type.blockchain_balance(build(:ethereum_address_1)) }

    it 'gets balance from a contract' do
      # Get it using VCR from blockchain
      is_expected.to eq 0
    end
  end

  describe 'human url' do
    let(:attrs) { { contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', blockchain: Blockchain::EthereumRopsten.new } }

    subject { described_class.new(**attrs) }

    specify { expect(subject.human_url).to eq 'https://ropsten.etherscan.io/address/0x583cbbb8a8443b38abcc0c956bece47340ea1367' }
    specify { expect(subject.human_url_name).to eq '0x583cbbb8a8443b38abcc0c956bece47340ea1367' }
  end
end
