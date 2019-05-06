require 'rails_helper'

RSpec.describe AuthenticationTeam, type: :model do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Account can't be blank",
                                  "Authentication can't be blank",
                                  "Team can't be blank"
                                ])
    end
  end

  describe 'has many projects' do
    let!(:authentication) { create :authentication }
    let!(:project) { create :project, account: authentication.account }
    let!(:team) { create :team }

    it 'return projects' do
      team.build_authentication_team authentication
      authentication_team = team.authentication_teams.last
      expect(authentication_team.projects).to eq [project]
    end
  end
  describe 'helpers' do
    let(:auth_hash) do
      {
        'uid' => 'ACDSF',
        'provider' => 'slack',
        'credentials' => {
          'token' => 'xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa'
        },
        'extra' => {
          'user_info' => { 'user' => { 'profile' => { 'email' => 'bob@example.com', 'image_32' => 'https://avatars.com/avatars_32.jpg' } } },
          'team_info' => {
            'team' => {
              'icon' => {
                'image_34' => 'https://slack.example.com/team-image-34-px.jpg',
                'image_132' => 'https://slack.example.com/team-image-132px.jpg'
              }
            }
          }
        },
        'info' => {
          'email' => 'bob@example.com',
          'name' => 'Bob Roberts',
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'user_id' => 'slack user id',
          'team' => 'new team name',
          'team_id' => 'slack team id',
          'user' => 'bobroberts',
          'team_domain' => 'bobrobertsdomain'
        }
      }
    end
    let!(:authentication) { create :authentication, oauth_response: auth_hash }
    let!(:team) { create :team }
    let!(:discord_authentication) { create :authentication, provider: 'discord' }
    let!(:team1) { create :team, provider: 'discord' }

    before do
      team.build_authentication_team authentication
      team1.build_authentication_team discord_authentication
    end

    it 'get name from authentication' do
      authentication_team = authentication.authentication_teams.last
      expect(authentication_team.name).to eq 'Bob Roberts'
    end

    it 'get slack channels' do
      stub_slack_channel_list
      authentication_team = authentication.authentication_teams.last
      expect(authentication_team.channels).to eq ['a-channel-name']
    end

    it 'get discord channels' do
      stub_discord_channels
      authentication_team = discord_authentication.authentication_teams.last
      expect(authentication_team.channels).to eq [%w[general channel_id]]
    end
  end
end
