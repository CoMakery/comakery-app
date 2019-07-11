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
    let!(:award) { create(:award, amount: 1337, award_type: create(:award_type, project: project), account: other_auth.account) }

    it 'get contributors list' do
      get :index, params: { project_id: project.to_param }

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
      expect(assigns[:award_data][:contributions_summary_pie_chart]).to match_array([{ net_amount: 1337, name: 'John Doe' }])
      expect(assigns[:chart_data]).to match_array([{ value: 1337, label: 'John Doe' }])
      expect(assigns[:table_data]).to match_array([
                                                    {
                                                      image_url: 'http://test.host/assets/default_account_image-eee1531b23fb9820d114c626a7e4212a9c54f7cf8522720d6ba1454787299a53.jpg',
                                                      name: 'John Doe',
                                                      awards: [
                                                        {
                                                          name: 'Contribution',
                                                          total: '1,337'
                                                        }
                                                      ],
                                                      total: '1,337',
                                                      total_dec: 0.1337e4
                                                    }
                                                  ])
    end
  end
end
