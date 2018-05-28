require 'rails_helper'

describe 'teams' do
  let!(:team) { create :team }
  let!(:team1) { create :team, provider: 'discord' }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:discord_auth) { create :authentication, account: account, provider: 'discord' }
  let!(:account1) { create :account }
  let!(:authentication1) { create :authentication, account: account1 }
  let!(:discord_auth1) { create :authentication, account: account1, provider: 'discord' }
  let!(:project) { create :project, account: account }
  let!(:channel) { create :channel, team: team, project: project, channel_id: 'general' }

  before do
    team.build_authentication_team authentication, true
    team.build_authentication_team authentication1
    team1.build_authentication_team discord_auth
    team1.build_authentication_team discord_auth1
    # stub_discord_members
    stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
                          slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2'),
                          slack_user(first_name: 'owner', last_name: 'owner', user_id: 'owner_id')])
    login account
  end

  scenario 'user teams list', js: true do
    visit new_project_path
    click_link '+ add channel'
    select 'Slack', from: 'provider'
    expect(page).to have_content 'Team or Guild'
    expect(authentication.decorate.slack?).to eq true
  end
end
