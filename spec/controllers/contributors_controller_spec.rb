require 'rails_helper'

describe ContributorsController do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:issuer) { create(:authentication) }
  let!(:issuer_discord) { create(:authentication, account: issuer.account, provider: 'discord') }
  let!(:receiver) { create(:authentication) }
  let!(:receiver_discord) { create(:authentication, account: receiver.account, provider: 'discord') }
  let!(:other_auth) { create(:authentication) }
  let!(:different_team_account) { create(:authentication) }

  let(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000) }

  before do
    stub_discord_channels
    team.build_authentication_team issuer
    team.build_authentication_team receiver
    team.build_authentication_team other_auth
    discord_team.build_authentication_team issuer_discord
    discord_team.build_authentication_team receiver_discord
    project.channels.create(team: team, channel_id: '123')
    login(issuer.account)
  end
  describe '#index' do
    let!(:award) { create(:award, award_type: create(:award_type, project: project), account: other_auth.account) }

    it 'get contributors list' do
      get :index, params: { project_id: project.to_param }

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
      expect(assigns[:award_data][:contributions]).to match_array([{ net_amount: 1337, name: 'John Doe', avatar: '/assets/default_account_image.jpg' }])
    end
  end
end
