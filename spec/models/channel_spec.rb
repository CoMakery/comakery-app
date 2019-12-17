require 'rails_helper'

RSpec.describe Channel, type: :model do
  let!(:discord_team) { create :team, provider: 'discord' }

  before do
    stub_discord_channels
  end

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
      expect(channel1.fetch_channels).to eq [%w[general channel_id]]
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

  describe '.url' do
    let!(:slack_channel) { create(:channel) }
    let!(:discord_channel) { create(:channel, team: discord_team) }

    before do
      stub_discord_create_invite
    end

    it 'returns url for a Slack channel' do
      expect(slack_channel.url).to eq("https://#{slack_channel.team.domain}.slack.com/messages/#{slack_channel.channel_id}")
    end

    it 'returns url for a Discord channel' do
      expect(discord_channel.url).to include('https://discord.gg/invite_code')
    end
  end

  describe '.discord_invite_valid?' do
    let!(:discord_channel_w_valid_invite) { create(:channel, team: discord_team, discord_invite_code: '1', discord_invite_created_at: Time.current) }
    let!(:discord_channel_wo_invite) { create(:channel, team: discord_team) }
    let!(:discord_channel_w_expired_invite) { create(:channel, team: discord_team, discord_invite_code: '1', discord_invite_created_at: 100.years.ago) }

    it 'is truthy if invite is present and fresh' do
      expect(discord_channel_w_valid_invite.discord_invite_valid?).to be_truthy
    end

    it 'is falsey if invite is not present' do
      expect(discord_channel_wo_invite.discord_invite_valid?).to be_falsey
    end

    it 'is falsey if invite is expired' do
      expect(discord_channel_w_expired_invite.discord_invite_valid?).to be_falsey
    end
  end

  describe '.fetch_discord_invite' do
    let!(:discord_channel) { create(:channel, team: discord_team) }

    before do
      stub_discord_create_invite
      discord_channel.fetch_discord_invite
    end

    it 'creates new invite' do
      expect(discord_channel.discord_invite_code).to include('invite_code')
    end

    it 'caches invite' do
      invite_created_at = discord_channel.discord_invite_created_at

      travel_to(1.hour.ago) do
        discord_channel.fetch_discord_invite

        expect(discord_channel.discord_invite_created_at).to eq invite_created_at
      end
    end

    it 'udpates cached invite' do
      invite_created_at = discord_channel.discord_invite_created_at

      travel_to((Channel::DISCORD_INVITE_MAX_AGE_SECONDS + 10).seconds.from_now) do
        discord_channel.fetch_discord_invite

        expect(discord_channel.discord_invite_created_at).not_to eq invite_created_at
      end
    end
  end
end
