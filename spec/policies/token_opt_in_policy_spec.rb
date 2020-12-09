require 'rails_helper'

describe TokenOptInPolicy do
  let(:token_opt_in) { create :token_opt_in }
  let(:wallet) { token_opt_in.wallet }
  let(:token) { token_opt_in.token }
  let(:account) { wallet.account }

  describe '#create?' do
    subject { described_class.new(account, token_opt_in).create? }
    it 'allow for non opted-in wallets' do
      is_expected.to be true
    end

    it 'deny for account without algorand wallet' do
      wallet.destroy!
      is_expected.to be false
    end

    it 'deny if account is not provided' do
      expect(described_class.new(nil, token_opt_in).create?).to be_falsey
    end

    it 'deny for not asa tokens' do
      token_opt_in.update!(token: create(:token))
      is_expected.to be false
    end
  end

  describe '#pay?' do
    subject { described_class.new(account, token_opt_in).pay? }
    it { is_expected.to be_truthy }
  end
end
