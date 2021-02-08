require 'rails_helper'

describe Comakery::Algorand::Tx::App do
  let!(:algorand_app_tx) { build(:algorand_app_tx) }
  let(:app_id) { algorand_app_tx.app_id }

  before do
    VCR.use_cassette("Algorand/transcation/#{algorand_app_tx.hash}") do
      algorand_app_tx.data
    end
  end

  describe '#algorand' do
    it 'returns Comakery::Algorand' do
      expect(algorand_app_tx.algorand).to be_a(Comakery::Algorand)
    end
  end

  describe '#app_accounts' do
    subject { algorand_app_tx.app_accounts }
    it { is_expected.to eq([]) }
  end

  describe '#app_args' do
    subject { algorand_app_tx.app_args }
    it { is_expected.to eq([]) }
  end

  describe '#transaction_app_id' do
    subject { algorand_app_tx.transaction_app_id }
    it { is_expected.to eq(app_id.to_i) }
  end

  describe '#transaction_app_accounts' do
    subject { algorand_app_tx.transaction_app_accounts }
    it { is_expected.to eq(['6447K33DMECECFTWCWQ6SDJLY7EYM47G4RC5RCOKPTX5KA5RCJOTLAK7LU']) }
  end

  describe '#transaction_app_args' do
    subject { algorand_app_tx.transaction_app_args }
    it { is_expected.to eq(['dHJhbnNmZXI=', 'Dw==']) }
  end

  describe '#transaction_on_completion' do
    subject { algorand_app_tx.transaction_on_completion }
    it { is_expected.to eq('noop') }
  end

  describe '#receiver_address' do
    subject { algorand_app_tx.receiver_address }
    it { is_expected.to eq(algorand_app_tx.transaction_app_accounts.first) }
  end

  describe '#to_object' do
    subject { algorand_app_tx.to_object }

    specify { expect(subject[:type]).to eq('appl') }
    specify { expect(subject[:from]).to eq(algorand_app_tx.blockchain_transaction.source) }
    specify { expect(subject[:to]).to be_nil }
    specify { expect(subject[:amount]).to be_nil }
    specify { expect(subject[:appIndex]).to eq(algorand_app_tx.app_id) }
    specify { expect(subject[:appAccounts]).to eq([]) }
    specify { expect(subject[:appArgs]).to eq([]) }
    specify { expect(subject[:appOnComplete]).to eq(0) }
  end

  describe 'encode_app_args' do
    context 'when arg is a String' do
      subject { algorand_app_tx.encode_app_args(['dummy']).first }

      it { is_expected.to eq('ZHVtbXk=') }
    end

    context 'when arg is an Integer' do
      subject { algorand_app_tx.encode_app_args([1999]).first }

      it { is_expected.to eq([124, 15]) }
    end

    context 'when arg is an Integer which should be encoded as base64' do
      subject { algorand_app_tx.encode_app_args([1999], true).first }

      it { is_expected.to eq('fA==') }
    end

    context 'when arg is unsupported' do
      subject { algorand_app_tx.encode_app_args([1.9]).first }

      it { expect { subject }.to raise_exception }
    end
  end

  describe 'encode_app_transaction_on_completion' do
    context 'when noop' do
      subject { algorand_app_tx.encode_app_transaction_on_completion('noop') }
      it { is_expected.to eq(0) }
    end

    context 'when optin' do
      subject { algorand_app_tx.encode_app_transaction_on_completion('optin') }
      it { is_expected.to eq(1) }
    end
  end

  describe '#valid?' do
    subject { algorand_app_tx.valid? }
    before { allow(algorand_app_tx.blockchain_transaction).to receive(:current_block).and_return(algorand_app_tx.confirmed_round - 1) }
    before { allow(algorand_app_tx).to receive(:app_accounts).and_return(['6447K33DMECECFTWCWQ6SDJLY7EYM47G4RC5RCOKPTX5KA5RCJOTLAK7LU']) }
    before { allow(algorand_app_tx).to receive(:app_args).and_return(['transfer', 15]) }

    context 'for incorrect app_id' do
      before { allow(algorand_app_tx).to receive(:app_id).and_return('0') }

      it { is_expected.to be false }
    end

    context 'for incorrect app_accounts' do
      before { allow(algorand_app_tx).to receive(:app_accounts).and_return([0]) }

      it { is_expected.to be false }
    end

    context 'for incorrect app_args' do
      before { allow(algorand_app_tx).to receive(:app_args).and_return([0]) }

      it { is_expected.to be false }
    end

    context 'for incorrect app_transaction_on_completion' do
      before { allow(algorand_app_tx).to receive(:app_transaction_on_completion).and_return('op') }

      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
