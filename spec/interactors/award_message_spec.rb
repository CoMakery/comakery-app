require 'rails_helper'

describe AwardMessage do
  include ::Rails.application.routes.url_helpers
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:authentication) { create :authentication }
  let!(:issuer) { authentication.account }
  let!(:other_auth) { create(:authentication, account: issuer, token: 'token') }
  let!(:project) { create(:project, account: issuer) }
  let!(:other_project) { create(:project, account: create(:account)) }
  let!(:award_type) { create(:award_type, project: project) }

  let(:recipient) { create(:account, email: 'glenn@example.com') }
  let(:recipient_authentication) { create(:authentication, account: recipient) }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team recipient_authentication
    discord_team.build_authentication_team authentication
    discord_team.build_authentication_team recipient_authentication
  end

  describe 'notifications_message' do
    it 'generates message' do
      channel = project.channels.create(team: team, channel_id: 'channel_id', name: 'slack_channel')
      award = create :award, award_type: award_type, issuer: issuer, account: recipient, channel: channel
      result = described_class.call(award: award)
      award = award.decorate

      expect(result.notifications_message).to eq "@#{award.issuer_user_name} accepted @#{award.recipient_user_name} task #{award.name} on the #{award.project.title} project: #{project_url(award.project)}. Login to CoMakery with your #{award.discord? ? 'Discord' : 'Slack'} account to claim project awards and start new tasks: #{new_session_url}."
    end
  end
end
