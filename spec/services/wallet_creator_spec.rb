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
    let(:asa_token) { create(:asa_token) }
    let(:ast_token) { create(:algo_sec_token) }
    let(:reg_group) { create(:reg_group, token: ast_token) }
    let(:tokens_to_provision) do
      [
        { token_id: asa_token.id.to_s },
        { token_id: ast_token.id.to_s, max_balance: '100', lockup_until: '1', reg_group_id: reg_group.id.to_s, account_frozen: 'false' }
      ]
    end

    it 'works' do
      wallet = wallets.first
      expect(Wallet.count).to eq 1
      expect(wallet).to be_persisted
      expect(wallet._blockchain).to eq 'algorand_test'
      expect(wallet.address).to be nil
      expect(wallet.source).to eq 'ore_id'

      provision_token_for_asa = WalletProvision.first
      expect(provision_token_for_asa.wallet).to eq wallet
      expect(provision_token_for_asa.token).to eq asa_token
      expect(provision_token_for_asa.state).to eq 'pending'

      provision_token_for_ast = WalletProvision.last
      expect(provision_token_for_ast.wallet).to eq wallet
      expect(provision_token_for_ast.token).to eq ast_token
      expect(provision_token_for_ast.state).to eq 'pending'

      account_token_record_for_ast = AccountTokenRecord.last
      expect(account_token_record_for_ast.wallet).to eq wallet
      expect(account_token_record_for_ast.token).to eq ast_token
      expect(account_token_record_for_ast.account).to eq account
      expect(account_token_record_for_ast.status).to eq 'created'
      expect(account_token_record_for_ast.max_balance).to eq 100
      expect(account_token_record_for_ast.lockup_until.to_i).to eq 1
      expect(account_token_record_for_ast.reg_group).to eq reg_group
      expect(account_token_record_for_ast.account_frozen).to eq false
    end

    context 'tokens_to_provision with asa token and no params' do
      let(:tokens_to_provision) { [{ token_id: asa_token.id.to_s, max_balance: '100', lockup_until: '1', reg_group_id: reg_group.id.to_s, account_frozen: 'false' }] }
      it { expect(wallets[0].errors).to be_empty }
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

    context 'token_id is not provided' do
      let(:tokens_to_provision) { [{ no_token_id: true }] }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ['token_id param must be provided']) }
    end

    context 'unexisting token id in tokens_to_provision' do
      let(:tokens_to_provision) { [{ token_id: '9999' }] }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ["Some tokens can't be provisioned: [9999]"]) }
    end

    context 'tokens_to_provision with existing token which can not be provisioned' do
      let(:token) { create(:token) }
      let(:tokens_to_provision) { [{ token_id: token.id.to_s }] }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ["Some tokens can't be provisioned: [#{token.id}]"]) }
    end

    context 'tokens_to_provision with algorand sec token and no params' do
      let(:token) { create(:algo_sec_token) }
      let(:tokens_to_provision) { [{ token_id: token.id.to_s }] }
      it { expect(wallets[0].errors.messages).to eq(tokens_to_provision: ["Token #{token.id} requires to provide additional params: max_balance, lockup_until, reg_group_id, account_frozen"]) }
    end
  end
end
