require 'rails_helper'
require 'models/concerns/belongs_to_blockchain_spec'

describe Wallet, type: :model do
  it_behaves_like 'belongs_to_blockchain', { blockchain_addressable_columns: [:address] }

  subject { create(:wallet) }
  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:balances).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_uniqueness_of(:_blockchain).scoped_to(:account_id).with_message('has already wallet added').ignoring_case_sensitivity }
  it { is_expected.to have_readonly_attribute(:_blockchain) }
  it { is_expected.to define_enum_for(:state).with_values({ ok: 0, unclaimed: 1, pending: 2 }) }
  it { is_expected.to define_enum_for(:source).with_values({ user_provided: 0, ore_id: 1 }) }

  describe '#available_blockchains' do
    it 'returns list of avaiable blockchains for creating a new wallet with the same account' do
      expect(subject.available_blockchains).not_to include(subject._blockchain)
    end
  end

  describe '#pending_for_ore_id' do
    context 'when created wallet source is ore_id' do
      subject { create(:wallet, source: :ore_id) }
      specify { expect(subject.state).to eq('pending') }
    end

    context 'when created wallet source is not ore_id' do
      subject { create(:wallet, source: :user_provided) }
      specify { expect(subject.state).to eq('ok') }
    end
  end

  describe '#ore_id_password_reset_url' do
    context 'when wallet source is ore_id and provided redirect_url is localhost' do
      subject { create(:wallet, source: :ore_id) }
      specify { expect(subject.ore_id_password_reset_url('fb.com')).to eq('https://example.org?redirect=localhost') }
    end

    context 'when wallet source is not ore_id' do
      subject { create(:wallet, source: :user_provided) }
      specify { expect(subject.ore_id_password_reset_url('fb.com')).to be_nil }
    end
  end
end
