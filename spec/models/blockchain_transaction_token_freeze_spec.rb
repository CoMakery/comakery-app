require 'rails_helper'

describe BlockchainTransactionTokenFreeze do
  subject { create(:blockchain_transaction_token_freeze) }

  specify { expect(subject.on_chain).to be_a(Comakery::Algorand::Tx::App::SecurityToken::Pause) }
  specify { expect(subject.token).to eq(subject.blockchain_transactable) }

  context 'when succeed' do
    before do
      subject.token.update(token_frozen: false)
      subject.update(tx_hash: '0')
      subject.update_status(:pending, 'test')
      subject.update_status(:succeed)
    end

    specify { expect(subject.blockchain_transactable.token_frozen).to be_truthy }
  end
end
