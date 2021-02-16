require 'rails_helper'

describe Comakery::Algorand::Tx::Asset::OptIn do
  let(:tx) { build(:algorand_asset_opt_in_tx) }
  subject { tx }
  it { is_expected.to be_a(Comakery::Algorand::Tx::Asset) }

  describe '#to_object' do
    subject { tx.to_object }

    specify { expect(subject[:type]).to eq('axfer') }
    specify { expect(subject[:from]).to eq(tx.blockchain_transaction.source) }
    specify { expect(subject[:to]).to eq(tx.blockchain_transaction.destination) }
    specify { expect(subject[:amount]).to eq(tx.blockchain_transaction.amount) }
    specify { expect(subject[:assetIndex]).to eq(tx.asset_id) }
  end
end
