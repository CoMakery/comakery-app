require 'rails_helper'

describe 'my account' do
  let!(:account) { create :account, email: 'test@test.st' }

  scenario 'edit account infomation' do
    login account
    visit root_path
    first('.menu').click_link 'ACCOUNT'
    expect(page).to have_content 'Account Details'
    find('#toggle-edit').click
    fill_in 'account[first_name]', with: ''
    fill_in 'account[last_name]', with: ''
    click_on 'Save'
    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
    find('#toggle-edit').click
    fill_in 'account[first_name]', with: 'Tester'
    fill_in 'account[last_name]', with: 'Dev'
    click_on 'Save'
    expect(page).to have_content 'Your account details have been updated.'
    expect(page).to have_content 'Tester'
    expect(page).to have_content 'Dev'
  end
end
