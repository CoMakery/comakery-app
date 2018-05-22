require 'rails_helper'

describe AwardSlackUser do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:authentication) { create :authentication }
  let!(:issuer) { authentication.account }
  let!(:other_auth) { create(:authentication, account: issuer, token: 'token') }
  let!(:discord_auth) { create(:authentication, account: issuer, token: 'discord_token', provider: 'discord') }
  let!(:project) { create(:project, account: issuer) }
  let!(:other_project) { create(:project, account: create(:account)) }
  let!(:award_type) { create(:award_type, project: project) }

  let(:recipient) { create(:account, email: 'glenn@example.com') }
  let(:recipient_authentication) { create(:authentication, account: recipient) }
  let!(:recipient_discord_auth) { create(:authentication, account: recipient, provider: 'discord') }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team recipient_authentication
    discord_team.build_authentication_team discord_auth
    discord_team.build_authentication_team recipient_discord_auth
    project.channels.create(team: team, channel_id: 'channel_id', name: 'slack_channel')
  end

  context 'send email award' do
    it 'send award notification to email' do
      result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: nil, award_params: {
        description: 'This rocks!!11',
        uid: 'test@test.st'
      }, total_tokens_issued: 0)

      expect(result.award.confirm_token).not_to be_nil
      expect(result.award.email).to eq 'test@test.st'
    end
  end
end
