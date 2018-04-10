require 'rails_helper'

describe ChannelsController do
  let!(:team) { create :team }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:project) { create :project, account: account }

  before do
    team.build_authentication_team authentication
    stub_discord_members
    stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
                          slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2'),
                          slack_user(first_name: 'owner', last_name: 'owner', user_id: 'owner_id')])
    login account
  end

  describe '#users' do
    let!(:channel) { create :channel, team: team, project: project, name: 'channel' }
    let!(:team1) { create :team, provider: 'discord' }
    let!(:d_channel) { create :channel, team: team1, project: project }

    specify do
      get :users, xhr: true, params: { id: channel.id }
      expect(response.status).to eq(200)
      expect(assigns[:members]).to eq([['collab1 collab1 - @collab1collab1', 'collab1'], ['collab2 collab2 - @collab2collab2', 'collab2'], ['owner owner - @ownerowner', 'owner_id']])
    end

    specify do
      get :users, xhr: true, params: { id: d_channel.id }
      expect(response.status).to eq(200)
      expect(assigns[:members]).to eq([%w[jason 123], %w[bob 234]])
    end
  end
end
