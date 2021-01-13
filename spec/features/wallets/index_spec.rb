require 'rails_helper'

describe 'wallets page' do
  context 'when logged in' do
    let(:wallet) do
      create(:wallet)
    end

    before do
      login(wallet.account)
    end

    it 'loads' do
      visit wallets_url
      within('h4') { expect(page.text).to eq('Wallets') }
    end
  end

  context 'when logged out' do
    it 'redirects' do
      visit wallets_url
      expect(page).to have_current_path(new_account_path)
    end
  end
end
