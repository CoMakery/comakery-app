require 'rails_helper'

describe BlockchainTransactionTokenUnfreeze do
  it { is_expected.to have_many(:blockchain_transactables_tokens).dependent(:nullify) }
  it { is_expected.to respond_to(:blockchain_transactables) }

  subject { create(:blockchain_transaction_token_unfreeze) }

  specify { expect(subject.token).to eq(subject.blockchain_transactable) }

  context 'when succeed' do
    before do
      subject.token.update(token_frozen: true)
      subject.update(tx_hash: '0')
      subject.update_status(:pending, 'test')
      subject.update_status(:succeed)
    end

    specify { expect(subject.blockchain_transactable.token_frozen).to be_falsey }
  end

  describe '#on_chain' do
    context 'with Comakery Security Token' do
      subject { create(:blockchain_transaction_unpause) }

      specify { expect(subject.on_chain).to be_a(Comakery::Eth::Tx::Erc20::SecurityToken::Unpause) }
    end

    context 'with Algorand Security Token' do
      specify { expect(subject.on_chain).to be_a(Comakery::Algorand::Tx::App::SecurityToken::Unpause) }
    end
  end
end
