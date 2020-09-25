require 'rails_helper'

describe WalletPolicy do
  subject { described_class }

  permissions :new?, :create?, :index? do
    it 'always grants access' do
      expect(subject).to permit(nil, create(:wallet))
    end
  end

  permissions :show?, :edit?, :update?, :destroy? do
    let(:wallet) { create(:wallet) }

    context 'when wallet belongs to account' do
      it 'grants access' do
        expect(subject).to permit(wallet.account, wallet)
      end
    end

    context "when wallet doesn't belong to account" do
      it 'denies access' do
        expect(subject).not_to permit(create(:account), wallet)
      end
    end
  end

  describe WalletPolicy::Scope do
    subject { described_class }
    let(:wallet) { create(:wallet) }

    specify { expect(subject.new(nil, Wallet).resolve).not_to include(wallet) }
    specify { expect(subject.new(wallet.account, Wallet).resolve).to include(wallet) }
  end
end
