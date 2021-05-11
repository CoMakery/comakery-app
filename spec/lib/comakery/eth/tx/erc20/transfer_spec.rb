require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::Transfer, vcr: true do
  let!(:erc20_transfer) { build(:erc20_transfer) }

  describe '#method_name' do
    subject { erc20_transfer.method_name }

    it { is_expected.to eq('transfer') }
  end

  describe '#method_params' do
    subject { erc20_transfer.method_params }

    it { is_expected.to eq([erc20_transfer.blockchain_transaction.destination, erc20_transfer.blockchain_transaction.amount]) }
  end
end
