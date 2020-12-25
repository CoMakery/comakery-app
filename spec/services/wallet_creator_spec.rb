require 'rails_helper'

RSpec.describe WalletCreator do
  let(:account) { create(:account) }
  let(:wallet_params) { { _blockchain: 'algorand_test', address: nil, source: 'ore_id' } }
  let(:tokens_to_provision) { nil }

  subject { described_class.new(account: account).call(wallet_params, tokens_to_provision: tokens_to_provision) }

  context 'wallet created' do
    let(:wallet_address) { build(:bitcoin_address_1) }
    let(:wallet_params) { { _blockchain: :bitcoin, address: wallet_address } }

    it 'works' do
      wallet = subject
      expect(Wallet.count).to eq 1
      expect(wallet).to be_persisted
      expect(wallet._blockchain).to eq 'bitcoin'
      expect(wallet.address).to eq wallet_address
      expect(wallet.source).to eq 'user_provided'

      expect(WalletProvision.count).to be_zero
    end
  end

  context 'wallet created with tokens_to_provision' do
    let(:token) { create(:asa_token) }
    let(:tokens_to_provision) { "[#{token.id}]" }

    it 'works' do
      wallet = subject
      expect(Wallet.count).to eq 1
      expect(wallet).to be_persisted
      expect(wallet._blockchain).to eq 'algorand_test'
      expect(wallet.address).to be nil
      expect(wallet.source).to eq 'ore_id'

      provision = WalletProvision.last
      expect(provision.wallet).to eq wallet
      expect(provision.token).to eq token
      expect(provision.state).to eq 'pending'
    end
  end

  context 'with invalid data' do
    after do
      expect(Wallet.count).to be_zero
      expect(WalletProvision.count).to be_zero
    end

    context 'wrong format of tokens_to_provision with valid JSON' do
      let(:tokens_to_provision) { '1' }
      it { expect(subject.errors.messages).to eq(tokens_to_provision: ['Wrong format. It must be an Array. For example: [1,5]']) }
    end

    context 'wrong format of tokens_to_provision with invalid JSON' do
      let(:tokens_to_provision) { '[1' }
      it { expect(subject.errors.messages).to eq(tokens_to_provision: ['Wrong format. It must be an Array. For example: [1,5]']) }
    end

    context 'unexisting token id in tokens_to_provision' do
      let(:tokens_to_provision) { '[9999]' }
      it { expect(subject.errors.messages).to eq(tokens_to_provision: ['Some tokens can\'t be provisioned: [9999]']) }
    end

    context 'tokens_to_provision with existing token which can not be provisioned' do
      let(:token) { create(:token) }
      let(:tokens_to_provision) { "[#{token.id}]" }
      it { expect(subject.errors.messages).to eq(tokens_to_provision: ["Some tokens can't be provisioned: [#{token.id}]"]) }
    end
  end
end
