require 'rails_helper'

describe 'awards issuing', js: true do
  let!(:team) { create(:team) }
  let!(:current_auth) { create(:sb_authentication) }
  let!(:awardee_auth) { create(:sb_authentication, account: create(:account, first_name: 'A', ethereum_wallet: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367')) }
  let!(:awardee_auth2) { create(:sb_authentication, account: create(:account, first_name: 'Z', ethereum_wallet: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1368')) }
  let!(:project1) { create(:sb_project, account: current_auth.account, maximum_tokens: 10, token: create(:token, decimal_places: 8, coin_type: 'erc20')) }
  let!(:channel1) { create(:channel, team: team, project: project1, name: 'channel1') }
  let!(:award_type1) { create(:award_type, project: project1) }
  let!(:award1) { create(:award_ready, award_type: award_type1, amount: 1) }
  let!(:award2) { create(:award_ready, award_type: award_type1, amount: 1) }
  let!(:award3) { create(:award_ready, award_type: award_type1, amount: 1) }
  let!(:award4) { create(:award_ready, award_type: award_type1, amount: 1) }
  let!(:award5) { create(:award_ready, award_type: award_type1, amount: 1) }
  let!(:award6) { create(:award, award_type: award_type1, amount: 1) }

  before do
    team.build_authentication_team current_auth
    team.build_authentication_team awardee_auth
    team.build_authentication_team awardee_auth2
    login(current_auth.account)
    stub_slack_user_list(slack_users_from_auths([awardee_auth, awardee_auth2]))
    allow_any_instance_of(Award).to receive(:send_award_notifications)
  end

  it 'allows to create award' do
    visit project_award_types_path(project1)
    find('.batch-index--sidebar--item', text: award_type1.name.capitalize).click
    find_link('create a task +').click
    expect(page).to have_content 'Create A New Task'
    fill_in 'task[name]', with: 'test name'
    fill_in 'task[why]', with: 'test why'
    fill_in 'task[description]', with: 'test description'
    fill_in 'task[requirements]', with: 'test requirements'
    find('select[name="task[experience_level]"] > option:nth-child(2)').click
    fill_in 'task[amount]', with: '1'
    fill_in 'task[proof_link]', with: 'http://test'
    find_button('create').click
    expect(page).to have_content 'TASK CREATED'
    expect(Award.last.name).to eq 'test name'
    expect(Award.last.why).to eq 'test why'
    expect(Award.last.description).to eq 'test description'
    expect(Award.last.requirements).to eq 'test requirements'
    expect(Award.last.experience_level).not_to eq 0
    expect(Award.last.amount).to eq 1
    expect(Award.last.proof_link).to eq 'http://test'
  end

  it 'allows to clone award' do
    visit project_award_types_path(project1)
    find('.batch-index--sidebar--item', text: award_type1.name.capitalize).click
    find("a[href='#{project_award_type_award_clone_path(project1, award_type1, award1)}']").click
    expect(page).to have_content 'Create A New Task'
    fill_in 'task[name]', with: 'test name cloned'
    find_button('create').click
    expect(page).to have_content 'TASK CREATED'
    expect(Award.last.name).to eq 'test name cloned'
    expect(Award.last.why).to eq award1.why
    expect(Award.last.description).to eq award1.description
    expect(Award.last.requirements).to eq award1.requirements
    expect(Award.last.amount).to eq award1.amount
    expect(Award.last.proof_link).to eq award1.proof_link
  end

  it 'allows to edit award' do
    visit project_award_types_path(project1)
    find('.batch-index--sidebar--item', text: award_type1.name.capitalize).click
    find("a[href='#{edit_project_award_type_award_path(project1, award_type1, award1)}']").click
    expect(page).to have_content 'Edit Task'
    fill_in 'task[name]', with: 'test name updated'
    find_button('save').click
    expect(page).to have_content 'TASK UPDATED'
    expect(award1.reload.name).to eq 'test name updated'
  end

  it 'allows to cancel award' do
    visit project_award_types_path(project1)
    find('.batch-index--sidebar--item', text: award_type1.name.capitalize).click
    find("a[data-method='delete'][href='#{project_award_type_award_path(project1, award_type1, award2)}']").click
    expect(page).to have_content 'TASK CANCELLED'
  end

  it 'allows to send award when recipient wallet address is present' do
    visit project_award_type_award_award_path(project1, award_type1, award3)
    find_button('proceed').click
    find('.task-award-form--form--field--title', text: 'RECIPIENT ADDRESS')
    expect(page).to have_content '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367'
    find_button('issue award').click
    expect(page).to have_content 'TASK HAS BEEN ACCEPTED.'
  end

  it 'allows to send award to a selected channel user' do
    visit project_award_type_award_award_path(project1, award_type1, award3)
    select channel1.channel_id, from: 'task[channel_id]'
    find('select[name="task[uid]"] > option:nth-child(2)').click
    find_button('proceed').click
    find('.task-award-form--form--field--title', text: 'RECIPIENT ADDRESS')
    expect(page).to have_content awardee_auth2.account.ethereum_wallet
    find_button('issue award').click
    expect(page).to have_content 'TASK HAS BEEN ACCEPTED.'
  end

  it "allows to send award when recipient wallet address isn't present" do
    visit project_award_type_award_award_path(project1, award_type1, award4)
    select 'email', from: 'task[channel_id]'
    find_field('task[email]').set 'test@test.test'
    find_button('proceed').click
    find('.task-award-form--form--field--title', text: 'RECIPIENT ADDRESS')
    expect(page).to have_content 'The recipient must register their address before they can accept the award.'
    find_button('issue award').click
    expect(page).to have_content "The award recipient hasn't entered a blockchain address for us to send the award to. When the recipient enters their blockchain address you will be able to approve the token transfer on the awards page.".upcase
  end

  it 'limit send award with project maximum token' do
    visit project_award_type_award_award_path(project1, award_type1, award5)
    fill_in 'task[quantity]', with: 100
    find_button('proceed').click
    find_button('issue award').click
    find('.flash-message-container')
    expect(page).to have_content "SORRY, YOU CAN'T EXCEED THE PROJECT'S BUDGET"
  end

  it "doesn't allow to edit award after sending" do
    visit project_award_types_path(project1)
    find('.batch-index--sidebar--item', text: award_type1.name.capitalize).click
    expect(page).not_to have_selector "a[href='#{edit_project_award_type_award_path(project1, award_type1, award6)}']"
  end

  it "doesn't allow to delete award after sending" do
    visit project_award_types_path(project1)
    find('.batch-index--sidebar--item', text: award_type1.name.capitalize).click
    expect(page).not_to have_selector "a[data-method='delete'][href='#{project_award_type_award_award_path(project1, award_type1, award6)}']"
  end
end
