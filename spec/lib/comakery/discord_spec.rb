require 'rails_helper'

describe Comakery::Discord do
  let!(:team) { create :team, provider: 'discord' }
  let!(:recipient) { create(:account, first_name: 'newt') }
  let!(:recipient_authentication) { create(:authentication, account: recipient, provider: 'discord') }
  let!(:issuer) { create :account, first_name: 'jim' }
  let!(:issuer_authentication) { create :authentication, account: issuer, token: 'xyz', provider: 'discord' }

  let!(:project) { create :project }
  let!(:discord_client) { described_class.new }

  before do
    team.build_authentication_team issuer_authentication
    team.build_authentication_team recipient_authentication
    stub_discord_channels
  end

  describe '#get' do
    it 'return link request to add bot to a guild' do
      discord_client = described_class.new
      expect(discord_client.add_bot_link).to match 'scope=bot&permissions=536870913'
    end

    it 'return list of guilds' do
      stub_discord_guilds
      expect(discord_client.guilds).to eq [{ 'icon' => nil, 'id' => 'team_id', 'name' => 'discord guild', 'permissions' => 40 }]
    end

    it 'return list of guild channels' do
      stub_discord_guilds
      expect(discord_client.channels(team)).to eq [{ 'icon' => nil, 'id' => 'team_id', 'name' => 'discord guild', 'permissions' => 40 }]
    end

    it 'return list of guild members' do
      stub_discord_members
      expect(discord_client.members(team)).to eq [{ 'user' => { 'id' => '123', 'username' => 'jason', 'name' => 'Jason' } }, { 'user' => { 'id' => '234', 'username' => 'bob', 'name' => 'Bob' } }]
    end
  end

  describe 'webhooks' do
    let!(:channel) { create :channel, project: project, team: team, name: 'general' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, channel: channel, award_type: award_type, issuer: issuer, account: recipient, quantity: 2 }

    it 'send message to discord' do
      stub_discord_webhooks
      expect(discord_client.send_message(award)).to be_truthy
    end

    it 'create a webhook' do
      stub_create_discord_webhooks
      expect(discord_client.webhook(channel.channel_id)['name']).to eq 'Comakery'
    end
  end

  describe 'create_invite' do
    let!(:channel) { create :channel, team: team }

    before do
      stub_discord_create_invite
    end

    it 'returns invite code' do
      response = discord_client.create_invite(channel.channel_id)
      expect(response).to include('invite_code')
    end
  end

  describe '.enabled?' do
    subject { described_class.enabled? }

    context 'when DISCORD_BOT_TOKEN and DISCORD_CLIENT_ID defined' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => 'DISCORD_BOT_TOKEN'))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => 'DISCORD_CLIENT_ID'))
      end

      it { is_expected.to be_truthy }
    end

    context 'when only DISCORD_BOT_TOKEN defined' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => 'DISCORD_BOT_TOKEN'))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => nil))
      end

      it { is_expected.to be_falsey }
    end

    context 'when only DISCORD_CLIENT_ID defined' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => nil))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => 'DISCORD_CLIENT_ID'))
      end

      it { is_expected.to be_falsey }
    end

    context 'when only DISCORD_BOT_TOKEN defined and DISCORD_CLIENT_ID is blank' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => 'DISCORD_BOT_TOKEN'))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => ''))
      end

      it { is_expected.to be_falsey }
    end

    context 'when only DISCORD_CLIENT_ID defined and DISCORD_BOT_TOKEN is blank' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => ''))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => 'DISCORD_CLIENT_ID'))
      end

      it { is_expected.to be_falsey }
    end

    context 'when both constants missing' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => nil))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => nil))
      end

      it { is_expected.to be_falsey }
    end

    context 'when both constants are blank' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISCORD_BOT_TOKEN' => ''))
        stub_const('ENV', ENV.to_hash.merge('DISCORD_CLIENT_ID' => ''))
      end

      it { is_expected.to be_falsey }
    end
  end
end
