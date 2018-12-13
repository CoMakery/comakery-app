require 'rails_helper'

describe 'my account', js: true do
  let!(:unconfirmed_account) { create :account, nickname: 'jason', email_confirm_token: '0' }
  let!(:to_be_confirmed_account) { create :account, nickname: 'jason', email_confirm_token: '1' }
  let!(:confirmed_account) { create :account, nickname: 'jason', email_confirm_token: nil }

  scenario 'user gets redirected to survey page after signup' do
    visit root_path
    first('.menu').click_link 'SIGN UP'
    expect(page).to have_content 'SIGN UP'
    click_on 'CREATE YOUR ACCOUNT'
    expect(page).to have_content("can't be blank", count: 4)
    fill_in 'account[email]', with: 'test@test.st'
    fill_in 'First Name', with: 'Tester'
    fill_in 'Last Name', with: 'Dev'
    fill_in 'Date of Birth', with: '01/01/2000'
    fill_in 'Password', with: '12345678'
    page.check('account_agreed_to_user_agreement')
    click_on 'CREATE YOUR ACCOUNT'
    expect(Account.last&.decorate&.name).to eq 'Tester Dev'
    expect(page).to have_content('SIGN OUT')
    expect(page).to have_content('FILL OUT THE SHORT FORM BELOW TO GET STARTED')
    expect(page).not_to have_content('Please confirm your email before continuing.')
  end

  scenario 'featured page is available after signup' do
    login(unconfirmed_account)
    visit '/featured'
    expect(status_code).to eq(200)
    expect(page).to have_content('Please confirm your email before continuing.')
    stub_airtable
    click_on "I'M INTERESTED!", match: :first
    wait_for_ajax
    expect(unconfirmed_account.interests.count).to be > 0
    expect(page).to have_content('INTEREST, NOTED!')
  end

  scenario 'account page is available after signup' do
    login(unconfirmed_account)
    visit '/account'
    expect(status_code).to eq(200)
    expect(page).not_to have_content('Please confirm your email before continuing.')
  end

  scenario 'projects page is unavailable after signup' do
    login(unconfirmed_account)
    visit '/projects'
    expect(status_code).to eq(200)
    expect(page).to have_content('Please confirm your email before continuing.')
  end

  scenario 'my projects page is unavailable after signup' do
    login(unconfirmed_account)
    visit '/projects/mine'
    expect(status_code).to eq(200)
    expect(page).to have_content('Please confirm your email before continuing.')
  end

  scenario 'account gets confirmed after visiting confirmation link' do
    visit "/accounts/confirm/#{to_be_confirmed_account.email_confirm_token}"
    expect(status_code).to eq(200)
    expect(page).to have_content('Success! Your email is confirmed.')
    expect(page).to have_content('SIGN OUT')
  end

  scenario 'projects page is available after email confirmation' do
    login(confirmed_account)
    visit '/projects'
    expect(status_code).to eq(200)
    expect(page).not_to have_content('Please confirm your email before continuing.')
  end

  scenario 'my projects page is available after email confirmation' do
    login(confirmed_account)
    visit '/projects/mine'
    expect(status_code).to eq(200)
    expect(page).not_to have_content('Please confirm your email before continuing.')
  end
end
