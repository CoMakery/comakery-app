require 'rails_helper'

describe 'teams' do
  let!(:team) { create :team }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:project) { create :project, account: account }
  let!(:channel) { create :channel, team: team, project: project, channel_id: 'general' }

  before do
    team.build_authentication_team authentication, true
    stub_slack_channel_list
    stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
                          slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2'),
                          slack_user(first_name: 'owner', last_name: 'owner', user_id: 'owner_id')])
    login account
  end

  scenario 'user teams list', js: true do
    visit new_project_path
    find('.project-form--form--channels--add').click
    expect(page).to have_content 'TEAM OR GUILD'
    expect(page).to have_content 'CHANNEL'
  end
end
