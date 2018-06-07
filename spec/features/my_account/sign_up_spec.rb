require 'rails_helper'

describe 'my account' do
  scenario 'signup' do
    visit root_path
    click_link 'Sign up'
    expect(page).to have_content 'Signup'
    click_on 'Create Account'
    expect(page).to have_content("can't be blank", count: 4)
    fill_in 'account[email]', with: 'test@test.st'
    fill_in 'First Name', with: 'Tester'
    fill_in 'Last Name', with: 'Dev'
    fill_in 'Date of Birth', with: '2000/01/01'
    fill_in 'Password', with: '12345678'
    click_on 'Create Account'
    expect(page).to have_content('Created account successfully. Please confirm your email before continuing.')
    expect(Account.first&.decorate&.name).to eq 'Tester Dev'
  end
end
