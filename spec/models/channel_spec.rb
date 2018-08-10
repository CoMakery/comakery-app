require 'rails_helper'

RSpec.describe Channel, type: :model do
  describe '#validations' do
    it 'requires many attributes' do
      channel = described_class.new
      expect(channel).not_to be_valid
      expect(channel.errors.full_messages).to eq(["Channel can't be blank", "Team can't be blank", "Project can't be blank"])
    end
  end

  describe 'helpers' do
    let(:account) { create :account }
    let(:authentication) { create :authentication, account: account }
    let(:authentication1) { create :authentication, account: account, provider: 'discord' }
    let(:team) { create :team, name: 'My Team' }
    let(:team1) { create :team, name: 'My Team without manager role', provider: 'discord' }
    let(:team2) { create :team, name: 'My Team with manager role', provider: 'discord' }
    let(:project) { create :project, account: account }
    let(:channel) { create :channel, project: project, channel_id: 'general', team: team }
    let(:channel1) { create :channel, project: project, channel_id: 'text', team: team2 }

    before do
      team.build_authentication_team authentication
      team1.build_authentication_team authentication1, false
      team2.build_authentication_team authentication1, true
      stub_discord_channels
    end

    it 'return name with provider' do
      expect(channel.name_with_provider).to eq '[slack] My Team #general'
    end

    it '#fetch_channels' do
      stub_slack_channel_list
      expect(channel.fetch_channels).to eq ['a-channel-name']
      expect(channel1.fetch_channels).to eq [['Text Channels - general', 'channel_id']]
    end

    it 'return authorized teams' do
      expect(channel.teams.map(&:name)).to eq ['My Team']
      expect(channel1.teams.map(&:name)).to eq ['My Team with manager role']
    end

    it 'fetch memebers' do
      stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
                            slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2')])
      stub_discord_members
      expect(channel.members).to eq [['collab1 collab1 - @collab1collab1', 'collab1'], ['collab2 collab2 - @collab2collab2', 'collab2']]
      expect(channel1.members).to eq [%w[jason 123], %w[bob 234]]
    end

    it 'assign_name' do
      channel = create :channel, project: project, channel_id: 'general', team: team
      expect(channel.name).to eq 'general'
      channel = create :channel, project: project, channel_id: 'channel_id', team: team1
      expect(channel.name).to eq 'general'
    end

    it 'invalid_params' do
      attributes = {}
      expect(described_class.invalid_params(attributes)).to eq true
      attributes['channel_id'] = 1
      expect(described_class.invalid_params(attributes)).to eq true
      attributes['channel_id'] = nil
      attributes['team_id'] = 10
      expect(described_class.invalid_params(attributes)).to eq true
      attributes['channel_id'] = 1
      attributes['team_id'] = 10
      expect(described_class.invalid_params(attributes)).to eq false
    end
  end
end
