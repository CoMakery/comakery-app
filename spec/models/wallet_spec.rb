require 'rails_helper'
require 'models/concerns/belongs_to_blockchain_spec'

describe Wallet, type: :model do
  it_behaves_like 'belongs_to_blockchain', { blockchain_addressable_columns: [:address] }

  subject { build(:wallet) }
  it { is_expected.to belong_to(:account).optional }
  it { is_expected.to belong_to(:project).optional }
  it { is_expected.to belong_to(:ore_id_account).optional }
  it { is_expected.to have_many(:awards).with_foreign_key(:recipient_wallet_id).dependent(:nullify) }
  it { is_expected.to have_many(:balances).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_uniqueness_of(:_blockchain).scoped_to(:account_id, :primary_wallet).with_message('has primary wallet already').ignoring_case_sensitivity }
  it { is_expected.to have_readonly_attribute(:_blockchain) }
  it { is_expected.to define_enum_for(:source).with_values({ user_provided: 0, ore_id: 1, hot_wallet: 2 }) }
  it { is_expected.not_to validate_presence_of(:ore_id_account) }
  it { expect(subject.ore_id_account).to be_nil }
  it { is_expected.to validate_presence_of(:name) }
  it do
    is_expected.to(
      validate_uniqueness_of(:address)
        .scoped_to(:account_id, :_blockchain)
        .with_message('has already been taken for the blockchain')
        .ignoring_case_sensitivity
    )
  end

  context 'blockchain_supported_by_ore_id validation' do
    subject { wallet.valid? }

    context 'pass for supported blockchain' do
      let(:wallet) { build(:ore_id_wallet) }

      it { is_expected.to be true }
    end

    context 'fails on not supported blockchain' do
      let(:wallet) { build(:ore_id_wallet, _blockchain: 'bitcoin') }

      it do
        is_expected.to be false
        expect(wallet.errors.messages[:_blockchain]).to eq ['is not supported with ore_id source']
      end
    end
  end

  context 'when ore_id?' do
    subject { create(:ore_id_wallet) }

    it { is_expected.to validate_presence_of(:ore_id_account) }
    it { expect(subject.ore_id_account).to be_an(OreIdAccount) }

    it 'aborts destroy with an error' do
      subject.destroy
      subject.reload
      expect(subject).to be_persisted
      expect(subject.errors).not_to be_empty
    end

    context 'and wallet_provisions are empty' do
      it { is_expected.not_to validate_presence_of(:address) }
    end

    context 'and there is a pending wallet_provision' do
      let(:wallet_provision) { create(:wallet_provision, state: :pending) }
      subject { wallet_provision.wallet }

      it { is_expected.not_to validate_presence_of(:address) }
    end

    context 'and wallet_provisions are not empty' do
      let(:wallet_provision) { create(:wallet_provision, state: :provisioned) }
      subject { wallet_provision.wallet }

      it { is_expected.to validate_presence_of(:address) }
    end

    context 'and ore_id_account is unlinking' do
      before { allow_any_instance_of(OreIdAccount).to receive(:unlinking?).and_return(true) }

      it 'allows destroy' do
        subject.destroy!
        expect(subject).not_to be_persisted
      end
    end
  end

  describe '#available_blockchains' do
    subject { create(:wallet) }

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

  describe '#coin_balance', vcr: true do
    subject { create(:wallet, _blockchain: :algorand_test, address: build(:algorand_address_1)) }
    specify { expect(subject.coin_balance).to be_a(Balance) }
  end

  describe '#set_primary_flag' do
    subject do
      wallet.save
      wallet.primary_wallet
    end

    let(:wallet) { build(:wallet, _blockchain: :algorand_test, address: build(:algorand_address_1)) }
    let(:account) { wallet.account }

    it { is_expected.to be true }

    context 'when primary for this network already exists' do
      before do
        create(:wallet, account: account, primary_wallet: true, _blockchain: :algorand_test, address: build(:algorand_address_2))
      end

      it { is_expected.to be false }
    end

    context 'when primary exists for different network' do
      before do
        create(:wallet, account: account, primary_wallet: true, _blockchain: :bitcoin, address: build(:bitcoin_address_1))
      end

      it { is_expected.to be true }
    end
  end

  describe '#mark_first_wallet_as_primary' do
    let!(:wallet) { create(:wallet, primary_wallet: true, _blockchain: :algorand_test, address: build(:algorand_address_1)) }
    let!(:wallet2) { create(:wallet, _blockchain: :algorand_test, address: build(:algorand_address_2)) }

    it 'marks another wallet as primary' do
      wallet.destroy

      expect(wallet2.reload.primary_wallet).to be true
    end
  end

  describe '#validate presence of project_id' do
    let!(:wallet) { build(:wallet, _blockchain: :algorand_test, source: :hot_wallet, address: build(:algorand_address_1)) }

    it 'returns an error' do
      expect(wallet).to be_invalid
      expect(wallet.errors[:project_id]).to be_present
    end
  end

  describe '#validate presence of account_id' do
    let!(:wallet) { Wallet.new(_blockchain: :algorand_test, source: :user_provided, address: build(:algorand_address_1)) }

    it 'returns an error' do
      expect(wallet).to be_invalid
      expect(wallet.errors[:account_id]).to be_present
    end
  end
end
