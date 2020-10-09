require 'rails_helper'

describe 'my account', js: true do
  let!(:account) { create :account, email: 'test@test.st' }

  before do
    login account
    visit account_path
    expect(page).to have_content 'Account Details'

    within('.view-ethereum-wallet') do
      first(:link).click
    end
  end

  scenario 'edit account information failed', js: true do
    fill_in 'firstName', with: '', fill_options: { clear: :backspace }
    fill_in 'lastName', with: '', fill_options: { clear: :backspace }
    find('input[type=submit]').click

    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
  end

  scenario 'edit account information success', js: true do
    fill_in 'firstName', with: 'Tester'
    fill_in 'lastName', with: 'Dev'

    find('input[type=submit]').click

    expect(page).to have_content 'Your account details have been updated.'
    expect(page).to have_content 'Tester'
    expect(page).to have_content 'Dev'
  end
end
