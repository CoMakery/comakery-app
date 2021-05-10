require 'rails_helper'

describe 'accounts index page', js: true do
  context 'with white label mission accounts' do
    let!(:whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: '') }
    let!(:account) { create(:account, managed_mission: whitelabel_mission, comakery_admin: true) }
    let!(:verification) { create(:verification, account: account, passed: false) }
    let!(:wallet) { create(:wallet, account: account) }

    before { login(account) }

    it 'show table with records' do
      visit accounts_path

      expect(page.all('#main-table tr').size).to eq(2)
    end

    context 'when the account is updated' do
      it 'broadcasts event' do
        visit accounts_path

        expect(page).to have_content('Eva Smith')

        account.update(first_name: 'John', last_name: 'Doe')

        expect(page).to have_content('John Doe')
      end
    end

    context 'when the wallet is updated' do
      it 'broadcasts event' do
        visit accounts_path

        expect(page).to have_content('3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt')

        wallet.update(address: '3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5')

        expect(page).to have_content('3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5')
      end
    end

    context 'when the verification is updated' do
      it 'broadcasts event' do
        visit accounts_path

        expect(page).to have_content('Failed')

        verification.update(passed: true)

        expect(page).to have_content('Accredited')
      end
    end

    context 'when the wallet was destroyed' do
      it 'broadcasts event' do
        visit accounts_path

        wallet.destroy

        expect(page.all('#main-table tr').size).to eq(1)
      end
    end
  end

  context 'without mission accounts' do
    let!(:account) { create(:account, comakery_admin: true) }

    before { create(:wallet, account: account, address: build(:bitcoin_address_2)) }

    before { login(account) }

    it 'show table with records' do
      visit accounts_path

      expect(page.all('#main-table tr').size).to eq(2)
    end
  end
end
