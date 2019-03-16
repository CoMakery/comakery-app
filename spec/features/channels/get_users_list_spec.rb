require 'rails_helper'

describe 'channels' do
  let!(:team) { create :team }
  let!(:team1) { create :team, provider: 'discord' }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:discord_auth) { create :authentication, account: account, provider: 'discord' }
  let!(:account1) { create :account }
  let!(:authentication1) { create :authentication, account: account1 }
  let!(:discord_auth1) { create :authentication, account: account1, provider: 'discord' }
  let!(:token) { create(:token) }
  let!(:mission) { create(:mission, token: token) }
  let!(:project) { create :project, account: account, mission: mission }
  let!(:channel) { create :channel, team: team, project: project, channel_id: 'general' }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team authentication1
    team1.build_authentication_team discord_auth
    team1.build_authentication_team discord_auth1
    # stub_discord_members
    stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
                          slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2'),
                          slack_user(first_name: 'owner', last_name: 'owner', user_id: 'owner_id')])
    login account
  end

  scenario 'get slack user list', js: true do
    visit project_path(project)
    expect(page.all('select#award_channel_id option').count).to eq(2)
    select "[slack] #{team.name} ##{channel.name}", from: 'Communication Channel'
  end

  scenario 'get discord user list', js: true do
    stub_discord_channels
    channel1 = create :channel, team: team1, project: project, channel_id: 'general'
    stub_discord_members
    visit project_path(project)
    expect(page.all('select#award_channel_id option').count).to eq(3)
    select "[discord] #{team1.name} ##{channel1.name}", from: 'Communication Channel'
  end
end
