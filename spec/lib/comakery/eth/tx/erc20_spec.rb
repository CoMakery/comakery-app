require 'rails_helper'

describe Comakery::Eth::Tx::Erc20, vcr: true do
  let!(:erc20_transfer) { build(:erc20_transfer, blockchain_transaction: build(:blockchain_transaction)) }

  describe '#to_object' do
    subject { erc20_transfer.to_object }

    specify { expect(subject[:from]).to eq(erc20_transfer.blockchain_transaction.source) }
    specify { expect(subject[:to]).to eq(erc20_transfer.blockchain_transaction.token.contract_address) }
    specify { expect(subject[:value]).to eq(erc20_transfer.encode_value(0)) }
    specify { expect(subject[:contract][:abi]).to eq(erc20_transfer.blockchain_transaction.token.abi) }
    specify { expect(subject[:contract][:method]).to eq(erc20_transfer.method_name) }
    specify { expect(subject[:contract][:parameters]).to eq(erc20_transfer.encode_method_params) }
  end

  describe '#method_name' do
    subject { erc20_transfer.method_name }

    it { is_expected.to eq('transfer') }
  end

  describe '#method_params' do
    subject { erc20_transfer.method_params }

    it { is_expected.to eq(['0xB4252b39f8506A711205B0b1C4170f0034065b46', 1]) }
  end

  describe '#encode_method_params' do
    subject { erc20_transfer.encode_method_params.first }

    context 'with a non-bool param' do
      before { allow(erc20_transfer).to receive(:method_params).and_return([1]) }
      it { is_expected.to be_a(String) }
    end

    context 'with a bool true param' do
      before { allow(erc20_transfer).to receive(:method_params).and_return([true]) }
      it { is_expected.to be_a(TrueClass) }
    end

    context 'with a bool false param' do
      before { allow(erc20_transfer).to receive(:method_params).and_return([false]) }
      it { is_expected.to be_a(FalseClass) }
    end
  end

  describe 'lookup_method_arg' do
    it 'returns n-th argument' do
      expect(erc20_transfer.lookup_method_arg(0)).to eq(762726034774768999117400353397232810765115688017)
      expect(erc20_transfer.lookup_method_arg(1)).to eq(100)
    end
  end
end
