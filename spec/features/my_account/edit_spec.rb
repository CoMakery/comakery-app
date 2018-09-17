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

    stub_token_symbol
    project = create(:project, ethereum_contract_address: '0x' + 'a' * 40)
    award_type = create :award_type, project: project
    award = create :award, award_type: award_type, account: account
    first('.menu').click_link 'ACCOUNT'
    expect(page).to have_content project.title
    award.update ethereum_transaction_address: '0x' + 'a' * 64
    expect(award.errors.full_messages).to eq []
    visit account_path(history: true)
    expect(page).to have_link award.decorate.ethereum_transaction_address_short
  end
end
