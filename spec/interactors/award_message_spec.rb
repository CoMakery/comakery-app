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

  context 'generate message' do
    it 'generate slack message' do
      channel = project.channels.create(team: team, channel_id: 'channel_id', name: 'slack_channel')
      award = create :award, award_type: award_type, issuer: issuer, account: recipient, channel: channel
      result = described_class.call(award: award)
      award = award.decorate
      expect(result.notifications_message).to eq "@#{award.issuer_user_name} sent @#{award.recipient_user_name} a #{award.total_amount} token #{award.award_type.name} for \"Great work\" on the <#{project_url(award.project)}|#{award.project.title}> project."
      project.update ethereum_enabled: true
      result = described_class.call(award: award.reload)
      award = award.decorate
      expect(result.notifications_message).to eq "@#{award.issuer_user_name} sent @#{award.recipient_user_name} a #{award.total_amount} token #{award.award_type.name} for \"Great work\" on the <#{project_url(award.project)}|#{award.project.title}> project. <#{account_url}|Set up your account> to receive Ethereum tokens."
    end

    it 'generate discord message' do
      stub_discord_channels
      channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'slack_channel')
      award = create :award, award_type: award_type, issuer: issuer, account: recipient, channel: channel
      result = described_class.call(award: award)
      award = award.decorate
      expect(result.notifications_message).to eq "@#{award.issuer_user_name} sent @#{award.recipient_user_name} a #{award.total_amount} token #{award.award_type.name} for \"Great work\" on the #{award.project.title} project: #{project_url(award.project)}."
      project.update ethereum_enabled: true
      result = described_class.call(award: award.reload)
      award = award.decorate
      expect(result.notifications_message).to eq "@#{award.issuer_user_name} sent @#{award.recipient_user_name} a #{award.total_amount} token #{award.award_type.name} for \"Great work\" on the #{award.project.title} project: #{project_url(award.project)}. Set up your account: #{account_url} to receive Ethereum tokens."
    end
  end
end
