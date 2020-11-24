require 'rails_helper'
require 'models/concerns/belongs_to_blockchain_spec'

describe Wallet, type: :model do
  it_behaves_like 'belongs_to_blockchain', { blockchain_addressable_columns: [:address] }

  subject { build(:wallet) }
  it { is_expected.to belong_to(:account) }
  it { is_expected.to belong_to(:ore_id_account).optional }
  it { is_expected.to have_many(:balances).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_uniqueness_of(:_blockchain).scoped_to(:account_id).with_message('has already wallet added').ignoring_case_sensitivity }
  it { is_expected.to have_readonly_attribute(:_blockchain) }
  it { is_expected.to define_enum_for(:source).with_values({ user_provided: 0, ore_id: 1 }) }
  it { is_expected.not_to validate_presence_of(:ore_id_account) }
  it { expect(subject.ore_id_account).to be_nil }

  context 'when ore_id?' do
    subject { create(:wallet, source: :ore_id) }

    it { is_expected.to validate_presence_of(:ore_id_account) }
    it { expect(subject.ore_id_account).to be_an(OreIdAccount) }

    it 'aborts destroy with an error' do
      subject.destroy
      subject.reload
      expect(subject).to be_persisted
      expect(subject.errors).not_to be_empty
    end

    context 'and ore_id_account is pending' do
      before { expect(subject).to receive(:pending?).and_return(true) }

      it { is_expected.not_to validate_presence_of(:address) }
    end
  end

  describe '#available_blockchains' do
    subject { create(:wallet) }

    it 'returns list of avaiable blockchains for creating a new wallet with the same account' do
      expect(subject.available_blockchains).not_to include(subject._blockchain)
    end

    it 'returns testnets if TESTNETS_AVAILABLE set to true' do
      allow(Blockchain).to receive(:testnets_available?).and_return(true)

      expect(subject.available_blockchains).to include('bitcoin_test')
      expect(subject.available_blockchains).to include('ethereum')
    end

    it 'doesnt return testnets if TESTNETS_AVAILABLE set to false' do
      allow(Blockchain).to receive(:testnets_available?).and_return(false)

      expect(subject.available_blockchains).not_to include('bitcoin_test')
      expect(subject.available_blockchains).to include('ethereum')
    end

    it 'doesnt include blockchains with supported_by_ore_id flag' do
      expect(subject.available_blockchains).not_to include('algorand')
    end
  end
end
