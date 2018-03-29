require 'rails_helper'

describe TeamsController do
  let!(:team) { create :team }
  let!(:team1) { create :team, provider: 'discord' }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:discord_auth) { create :authentication, provider: 'discord', account: account }

  before do
    team.build_authentication_team authentication
    team1.build_authentication_team discord_auth
    stub_slack_channel_list
    stub_discord_channels
    login account
  end

  describe '#index' do
    specify do
      get :index, xhr: true, params: { provider: 'slack', elem_id: 'team' }
      expect(response.status).to eq(200)
      expect(assigns[:teams].count).to eq(1)
      expect(assigns[:teams].first).to eq(team)
    end
  end

  describe '#channels' do
    it 'return channels list for slack' do
      get :channels, xhr: true, params: { id: team.id }
      expect(response.status).to eq(200)
      expect(assigns[:auth_team]).to eq(team.authentication_teams.first)
      expect(assigns[:channels]).to eq(['a-channel-name'])
    end

    it 'return channels list for discord' do
      authentication.destroy
      get :channels, xhr: true, params: { id: team1.id }
      expect(response.status).to eq(200)
      expect(assigns[:auth_team]).to eq(team1.authentication_teams.first)
      expect(assigns[:channels]).to eq([['Text Channels - general', 'channel_id']])
    end
  end
end
