require 'rails_helper'

describe 'my account' do
  scenario 'signup' do
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
    expect(page).to have_content('Created account successfully. Please confirm your email before continuing.')
    expect(Account.first&.decorate&.name).to eq 'Tester Dev'
  end
end
