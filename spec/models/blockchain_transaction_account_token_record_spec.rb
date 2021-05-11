require 'rails_helper'

describe BlockchainTransactionAccountTokenRecord, vcr: true do
  it { is_expected.to have_many(:blockchain_transactables_account_token_records).dependent(:nullify) }
  it { is_expected.to respond_to(:blockchain_transactables) }

  describe 'update_status' do
    let!(:blockchain_transaction) { create(:blockchain_transaction_account_token_record) }

    before do
      blockchain_transaction.update(tx_hash: '0')
      blockchain_transaction.update_status(:pending, 'test')
    end

    it 'marks transfer rule as synced if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.blockchain_transactable.status).to eq('synced')
    end
  end

  describe 'populate_data' do
    subject { create(:blockchain_transaction_account_token_record) }

    it 'populates' do
      expect(subject.destination).to eq(subject.blockchain_transactable.wallet.address)
    end
  end

  describe 'on_chain' do
    context 'with comakery security token' do
      subject { build(:blockchain_transaction_account_token_record).on_chain }
      specify { expect(subject).to be_an(Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions) }
    end

    context 'with algorand security token' do
      subject { build(:blockchain_transaction_account_token_record_algo).on_chain }
      specify { expect(subject).to be_an(Comakery::Algorand::Tx::App::SecurityToken::SetAddressPermissions) }
    end
  end
end
