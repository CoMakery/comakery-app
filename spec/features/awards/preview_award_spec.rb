require 'rails_helper'

describe 'preview award', js: true do
  let!(:account) { create(:account, email: 'hubert@example.com', first_name: 'Michael', last_name: 'Jackson') }
  let!(:small_award_type) { create(:award_type, project: project, name: 'Small', amount: 1000) }
  let!(:project) do
    stub_token_symbol
    create(:project, title: 'Project that needs awards', account: account, ethereum_enabled: true, ethereum_contract_address: '0x' + '2' * 40, revenue_sharing_end_date: Time.zone.now + 3.days, maximum_tokens: 10000000, maximum_royalties_per_month: 1000000, ethereum_network: 'ropsten', coin_type: 'erc20')
  end

  before do
    login(account)
    visit project_path(project)
  end

  it 'recipient has an ethereum account' do
    create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', ethereum_wallet: '0x' + 'a' * 40)

    fill_in 'Email Address', with: 'bobjohnson@example.com'
    page.find('body').click
    sleep 2
    expect(page.find('.preview_award_div')).to have_content '1000.0 FCBB total to ' + '0x' + 'a' * 40
    click_button 'Send'
    expect(page).to have_content 'Successfully sent award to bobjohnson'
    expect(EthereumTokenIssueJob.jobs.length).to eq(0)
  end

  it 'recipient has not an ethereum account' do
    create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com')

    fill_in 'Email Address', with: 'bobjohnson@example.com'
    page.find('body').click
    sleep 2
    expect(page.find('.preview_award_div')).to have_content '1000.0 FCBB'
  end
end
