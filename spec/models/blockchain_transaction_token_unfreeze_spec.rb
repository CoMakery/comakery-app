require 'rails_helper'

describe BlockchainTransactionTokenUnfreeze do
  subject { create(:blockchain_transaction_token_unfreeze) }

  specify { expect(subject.on_chain).to be_a(Comakery::Algorand::Tx::App::SecurityToken::Unfreeze) }
  specify { expect(subject.token).to eq(subject.blockchain_transactable) }

  context 'when succeed' do
    before do
      subject.token.update(token_frozen: true)
      subject.update_status(:pending, 'test')
      subject.update_status(:succeed)
    end

    specify { expect(subject.blockchain_transactable.token_frozen).to be_falsey }
  end
end
