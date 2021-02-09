require 'rails_helper'

describe 'build profile', js: true do
  context 'has no email set' do
    let(:account) do
      account = Account.new(ethereum_auth_address: '0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB')
      account.save(validate: false)
      account
    end

    before do
      login account
      visit root_path
    end

    scenario 'sees email field input', js: true do
      expect(page).to have_text('Setup Your Account')
      expect(page).to have_selector('input[name="account[email]"]')
    end
  end

  context 'has email set' do
    let(:account) do
      account = Account.new(ethereum_auth_address: '0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB', email: 'test@exmaple.com')
      account.save(validate: false)
      account
    end

    before do
      login account
      visit root_path
    end

    scenario 'sees email field input', js: true do
      expect(page).to have_text('Setup Your Account')
      expect(page).not_to have_selector('input[name="account[email]"]')
    end
  end
end
