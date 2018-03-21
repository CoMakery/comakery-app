require 'rails_helper'

describe TeamsController do
  let!(:team) { create :team }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }

  before do
    team.build_authentication_team authentication
    stub_slack_channel_list
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
    specify do
      get :channels, xhr: true, params: { id: team.id }
      expect(response.status).to eq(200)
      expect(assigns[:auth_team]).to eq(team.authentication_teams.first)
      expect(assigns[:channels]).to eq(['a-channel-name'])
    end
  end
end
