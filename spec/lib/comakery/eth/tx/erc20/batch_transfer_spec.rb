require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::BatchTransfer, vcr: true do
  let!(:erc20_batch_transfer) { build(:erc20_batch_transfer) }

  describe '#to_object' do
    subject { erc20_batch_transfer.to_object }

    specify { expect(subject[:to]).to eq(erc20_batch_transfer.blockchain_transaction.token.batch_contract_address) }
    specify { expect(subject[:contract][:abi]).to eq(erc20_batch_transfer.blockchain_transaction.token.batch_abi) }
    specify { expect(subject[:contract][:method]).to eq(erc20_batch_transfer.method_name) }
    specify { expect(subject[:contract][:parameters]).to eq(erc20_batch_transfer.encode_method_params_json) }
  end

  describe '#method_name' do
    subject { erc20_batch_transfer.method_name }

    it { is_expected.to eq('batchTransfer') }
  end

  describe '#method_params' do
    subject { erc20_batch_transfer.method_params }

    it {
      is_expected.to eq([
                          erc20_batch_transfer.blockchain_transaction.contract_address,
                          erc20_batch_transfer.blockchain_transaction.destinations,
                          erc20_batch_transfer.blockchain_transaction.amounts
                        ])
    }
  end

  describe '#abi' do
    subject { erc20_batch_transfer.abi }

    it { is_expected.to be_an(Array) }
  end

  describe '#valid_to?' do
    subject { erc20_batch_transfer.valid_to? }

    before do
      allow_any_instance_of(Token).to receive(:batch_contract_address).and_return('0x68ac9a329c688afbf1fc2e5d3e8cb6e88989e2cc')
    end

    it { is_expected.to be_truthy }

    context 'for transaction with incorrect destination' do
      before do
        allow_any_instance_of(described_class).to receive(:to).and_return('0x0')
      end

      it { is_expected.to be_falsey }
    end
  end
end
