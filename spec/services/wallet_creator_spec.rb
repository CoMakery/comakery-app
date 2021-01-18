require 'rails_helper'

RSpec.describe WalletCreator do
  subject(:wallets) { described_class.new(account: account).call(wallets_params).first }

  let(:account) { create(:account) }
  let(:wallets_params) do
    [{
      blockchain: 'algorand_test',
      address: nil,
      source: 'ore_id',
      tokens_to_provision: tokens_to_provision,
      name: 'Wallet'
    }]
  end
  let(:tokens_to_provision) { nil }

  context 'wallet created without tokens_to_provision' do
    let(:bitcoin_address) { build(:bitcoin_address_1) }
    let(:constellation_address) { build(:constellation_address_1) }
    let(:wallets_params) do
      [
        { blockchain: :bitcoin, address: bitcoin_address, tokens_to_provision: tokens_to_provision, name: 'Wallet 1' },
        { blockchain: :constellation, address: constellation_address, name: 'Wallet 2' }
      ]
    end

    it 'works' do
      wallets

      expect(Wallet.count).to eq 2
      expect(wallets.all?(&:persisted?)).to be true
      expect(wallets.map(&:_blockchain)).to eq %w[bitcoin constellation]
      expect(wallets.map(&:address)).to eq [bitcoin_address, constellation_address]
      expect(wallets.map(&:source)).to eq %w[user_provided user_provided]

      expect(WalletProvision.count).to be_zero
    end
  end

  context 'wallet created with tokens_to_provision' do
    let(:token) { create(:asa_token) }
    let(:tokens_to_provision) { [ActionController::Parameters.new(token_id: token.id.to_s).permit!] }

    it 'works' do
      wallet = wallets.first
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

    context 'wrong format of tokens_to_provision' do
      let(:tokens_to_provision) { '1' }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ['Wrong format. It must be an Array.']) }
    end

    context 'unexisting token id in tokens_to_provision' do
      let(:tokens_to_provision) { [ActionController::Parameters.new(token_id: '9999').permit!] }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ['Some tokens can\'t be provisioned: [9999]']) }
    end

    context 'tokens_to_provision with existing token which can not be provisioned' do
      let(:token) { create(:token) }
      let(:tokens_to_provision) { [ActionController::Parameters.new(token_id: token.id.to_s).permit!] }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ["Some tokens can't be provisioned: [#{token.id}]"]) }
    end
  end
end
