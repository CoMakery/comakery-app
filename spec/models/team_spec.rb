require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'association' do
    let!(:authentication) { create :authentication }
    let!(:team) { create :team }

    it 'has many authentication_teams' do
      team.build_authentication_team authentication
      expect(team.authentication_teams.count).to eq 1
    end

    it 'has many accounts' do
      team.build_authentication_team authentication
      expect(team.accounts).to eq [authentication.account]
    end
  end

  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account: account }
  let!(:discord_authentication) { create :authentication, provider: 'discord', account: account }

  it 'build_authentication_team' do
    team.build_authentication_team authentication
    auth_team = team.reload.authentication_teams.last
    expect(auth_team.account).to eq account
    expect(auth_team.authentication).to eq authentication
  end

  describe 'helpers' do
    before do
      team.build_authentication_team authentication
      discord_team.build_authentication_team discord_authentication
    end

    it 'get authentication_team by account' do
      auth_team = team.authentication_teams.last
      expect(team.authentication_team_by_account(account)).to eq auth_team
    end

    it 'check if team is discord team or not' do
      expect(team.discord?).to eq false
      expect(discord_team.discord?).to eq true
    end

    describe '#member' do
      it 'return emty array for slack' do
        expect(team.members).to eq []
      end

      it 'return memebers list for discord' do
        stub_discord_members
        expect(discord_team.members).to eq [{ 'user' => { 'id' => '123', 'username' => 'jason', 'name' => 'Jason' } }, { 'user' => { 'id' => '234', 'username' => 'bob', 'name' => 'Bob' } }]
      end

      it 'return memebers list for selectbox' do
        stub_discord_members
        expect(discord_team.members_for_select).to eq [%w[jason 123], %w[bob 234]]
      end
    end
  end
end
