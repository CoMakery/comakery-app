require 'rails_helper'

describe TeamDecorator do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:discord_authentication) { create :authentication, provider: 'discord', account: account }

  before do
    team.build_authentication_team authentication
    discord_team.build_authentication_team discord_authentication
    stub_discord_channels
  end

  describe 'display' do
    it 'list channels' do
      expect(discord_team.decorate.channels).to eq [{ 'parent_id' => nil, 'id' => 'parent_id', 'name' => 'Text Channels' }, { 'parent_id' => 'parent_id', 'id' => 'channel_id', 'name' => 'general' }]
    end

    it 'channel_name' do
      expect(discord_team.decorate.channel_name('channel_id')).to eq 'general'
    end

    it 'channel_for_selects' do
      expect(discord_team.decorate.channel_for_selects).to eq [%w[general channel_id]]
    end
  end
end
