require 'rails_helper'

describe 'reset password' do
  let!(:account) { create :account, email: 'test@test.st', password: '12345678' }

  scenario 'send reset password request' do
    visit new_session_path
    click_link 'Forgot?'
    fill_in 'email', with: 'invalid@test.st'
    click_on 'Reset my password!'
    expect(page).to have_content 'Could not found account with given email'
    fill_in 'email', with: 'test@test.st'
    click_on 'Reset my password!'
    expect(page).to have_content 'please check your email for reset password instructions'
  end
end
