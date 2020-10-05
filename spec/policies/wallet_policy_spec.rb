require 'rails_helper'

describe WalletPolicy do
  subject { described_class }

  permissions :new?, :index? do
    context 'when account is present' do
      it 'grants access' do
        expect(subject).to permit(create(:account), nil)
      end
    end

    context 'when account is not present' do
      it 'denies access' do
        expect(subject).not_to permit(nil, nil)
      end
    end
  end

  permissions :create?, :show?, :edit?, :update?, :destroy? do
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
