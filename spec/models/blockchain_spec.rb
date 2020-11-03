require 'rails_helper'

describe Blockchain, type: :model do
  subject { described_class }

  specify { expect(subject.list).to be_a(Hash) }
  specify { expect(subject.append_to_list(nil)).to be_a(Hash) }
  specify { expect(subject.all).to be_an(Array) }
  specify { expect(subject.find_with_ore_id_name(nil)).to be_nil }

  describe '#available' do
    subject { described_class.available }
    after { ENV['TESTNETS_AVAILABLE'] = 'true' }

    it 'returns testnets if TESTNETS_AVAILABLE set to true' do
      ENV['TESTNETS_AVAILABLE'] = 'true'

      is_expected.to include Blockchain::BitcoinTest
      is_expected.to include Blockchain::Bitcoin
    end

    it 'do not returns testnets if TESTNETS_AVAILABLE set to false' do
      ENV['TESTNETS_AVAILABLE'] = 'false'

      is_expected.not_to include Blockchain::BitcoinTest
      is_expected.to include Blockchain::Bitcoin
    end

    it 'returns testnets if TESTNETS_AVAILABLE not set' do
      ENV['TESTNETS_AVAILABLE'] = nil

      is_expected.to include Blockchain::BitcoinTest
      is_expected.to include Blockchain::Bitcoin
    end
  end
end

shared_examples 'a blockchain' do
  describe described_class.new do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:explorer_api_host) }
    it { is_expected.to respond_to(:explorer_human_host) }
    it { is_expected.to respond_to(:mainnet?) }
    it { is_expected.to respond_to(:number_of_confirmations) }
    it { is_expected.to respond_to(:sync_period) }
    it { is_expected.to respond_to(:sync_max) }
    it { is_expected.to respond_to(:sync_waiting) }
    it { is_expected.to respond_to(:url_for_tx_human).with(1).argument }
    it { is_expected.to respond_to(:url_for_tx_api).with(1).argument }
    it { is_expected.to respond_to(:url_for_address_human).with(1).argument }
    it { is_expected.to respond_to(:url_for_address_api).with(1).argument }
    it { is_expected.to respond_to(:validate_tx_hash).with(1).argument }
    it { is_expected.to respond_to(:validate_addr).with(1).argument }
    it { is_expected.to respond_to(:supported_by_ore_id?) }
    it { is_expected.to respond_to(:ore_id_name) }
  end

  describe 'validate_tx_hash' do
    context 'when supplied tx hash is incorrect' do
      it 'raises an error' do
        expect { described_class.new.validate_tx_hash('') }.to raise_error(Blockchain::Tx::ValidationError)
      end
    end
  end

  describe 'validate_addr' do
    context 'when supplied addr is incorrect' do
      it 'raises an error' do
        expect { described_class.new.validate_addr('0') }.to raise_error(Blockchain::Address::ValidationError)
      end
    end
  end
end
