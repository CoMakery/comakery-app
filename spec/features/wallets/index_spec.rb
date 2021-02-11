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

  context 'when has linked ORE ID wallet', js: true do
    let(:ore_id_account) { create(:ore_id, skip_jobs: true) }
    let!(:wallet) { create(:wallet, ore_id_account: ore_id_account, account: ore_id_account.account, _blockchain: :algorand_test, source: :ore_id, address: build(:algorand_address_1)) }
    let!(:asa_token) { create(:asa_token) }

    before do
      login(wallet.account)
    end

    it 'disaplays avaliable tokens for opt in' do
      visit wallets_path

      expect(find('table.table')).to have_content wallet.name

      find('.dropdown').click
      find('.dropdown-item.opt-ins').click

      expect(find('table.opt-ins')).to have_content asa_token.name
    end
  end
end
