require 'rails_helper'

describe Comakery::Eth::Tx::Erc20, vcr: true do
  let!(:erc20_transfer) { build(:erc20_transfer) }

  describe '#to_object' do
    subject { erc20_transfer.to_object }

    specify { expect(subject[:from]).to eq(erc20_transfer.blockchain_transaction.source) }
    specify { expect(subject[:to]).to eq(erc20_transfer.blockchain_transaction.token.contract_address) }
    specify { expect(subject[:value]).to eq(erc20_transfer.encode_value(0)) }
    specify { expect(subject[:contract][:abi]).to be_present }
    specify { expect(subject[:contract][:method]).to eq(erc20_transfer.method_name) }
    specify { expect(subject[:contract][:parameters]).to eq(erc20_transfer.encode_method_params_json) }
  end

  describe '#abi' do
    subject { erc20_transfer.abi }

    it { is_expected.to be_an(Array) }
  end

  describe '#method' do
    subject { erc20_transfer.method }

    it { is_expected.to be_an(Ethereum::Function) }
  end

  describe '#method_name' do
    subject { erc20_transfer.method_name }

    it { is_expected.to eq('transfer') }
  end

  describe '#method_id' do
    subject { erc20_transfer.method_id }

    it { is_expected.to eq('a9059cbb') }
  end

  describe '#method_params' do
    subject { erc20_transfer.method_params }

    it { is_expected.to eq(['0x8599d17ac1cec71ca30264ddfaaca83c334f8451', 100]) }
  end

  describe '#method_abi' do
    subject { erc20_transfer.method_abi }

    let(:erc20_transfer_abi) do
      [{
        'constant' => false,
        'inputs' => [
          { 'name' => '_to', 'type' => 'address' },
          { 'name' => '_value', 'type' => 'uint256' }
        ],
        'name' => 'transfer',
        'outputs' => [
          { 'name' => '', 'type' => 'bool' }
        ],
        'payable' => false,
        'stateMutability' => 'nonpayable',
        'type' => 'function'
      }]
    end

    it { is_expected.to match_array(erc20_transfer_abi) }
  end

  describe '#encode_method_params_json' do
    subject { erc20_transfer.encode_method_params_json.first }

    context 'with an array param' do
      before { allow(erc20_transfer).to receive(:method_params).and_return([[1]]) }
      it { is_expected.to be_an(Array) }
    end

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

  describe '#encode_method_params_hex' do
    subject { erc20_transfer.encode_method_params_hex }

    it { is_expected.to eq('0000000000000000000000008599d17ac1cec71ca30264ddfaaca83c334f84510000000000000000000000000000000000000000000000000000000000000064') }
  end

  describe '#valid_to?' do
    subject { erc20_transfer.valid_to? }

    it { is_expected.to be_truthy }

    context 'for transaction with incorrect destination' do
      before do
        allow_any_instance_of(described_class).to receive(:to).and_return('0x0')
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#valid_amount?' do
    subject { erc20_transfer.valid_amount? }

    it { is_expected.to be_truthy }

    context 'for transaction with incorrect amount' do
      before do
        allow_any_instance_of(described_class).to receive(:value).and_return(1)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#valid_method_id?' do
    subject { erc20_transfer.valid_method_id? }

    it { is_expected.to be_truthy }

    context 'for transaction with incorrect method id' do
      before do
        allow_any_instance_of(described_class).to receive(:input).and_return('0')
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#valid_method_params?' do
    subject { erc20_transfer.valid_method_params? }

    it { is_expected.to be_truthy }

    context 'for transaction with incorrect method params' do
      before do
        allow_any_instance_of(described_class).to receive(:input).and_return('000000000000000')
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#valid?' do
    subject { erc20_transfer.valid? }

    context 'for transaction with incorrect method id' do
      before do
        allow_any_instance_of(described_class).to receive(:input).and_return('0')
      end

      it { is_expected.to be_falsey }
    end

    context 'for transaction with incorrect method params' do
      before do
        allow_any_instance_of(described_class).to receive(:input).and_return('000000000000000')
      end

      it { is_expected.to be_falsey }
    end

    context 'for correct transaction' do
      it { is_expected.to be_truthy }
    end
  end
end
