require 'rails_helper'

describe Authentication do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Account can't be blank",
                                  "Provider can't be blank",
                                  "Uid can't be blank"
                                ])
    end
  end

  # describe 'slack_team_ethereum_enabled?' do
  #   describe 'when ENV whitelist is set' do
  #     before do
  #       Rails.application.config.allow_ethereum = 'foo,comakery'
  #     end
  #     it 'is true if the slack team domain is in the ENV whitelist' do
  #       auth = create(:authentication, slack_team_domain: 'comakery')
  #       expect(auth.slack_team_ethereum_enabled?).to eq true
  #     end
  #     it 'is false if the slack team domain is not in the ENV whitelist' do
  #       auth = create(:authentication, slack_team_domain: 'com0kery')
  #       expect(auth.slack_team_ethereum_enabled?).to eq false
  #     end
  #     it 'is false if the slack team domain is nil' do
  #       auth = create(:authentication, slack_team_domain: nil)
  #       expect(auth.slack_team_ethereum_enabled?).to eq false
  #     end
  #   end
  #
  #   describe 'when ENV whitelist is nil' do
  #     before do
  #       Rails.application.config.allow_ethereum = nil
  #     end
  #     it 'is false for a valid slack team domain' do
  #       auth = create(:authentication, slack_team_domain: 'comakery')
  #       expect(auth.slack_team_ethereum_enabled?).to eq false
  #     end
  #     it 'is false if the slack team domain is nil' do
  #       auth = create(:authentication, slack_team_domain: nil)
  #       expect(auth.slack_team_ethereum_enabled?).to eq false
  #     end
  #   end
  #
  #   describe 'when ENV whitelist is empty' do
  #     before do
  #       Rails.application.config.allow_ethereum = ''
  #     end
  #     it 'is false for a valid domain' do
  #       auth = create(:authentication, slack_team_domain: 'comakery')
  #       expect(auth.slack_team_ethereum_enabled?).to eq false
  #     end
  #     it 'is false if the slack team domain is nil' do
  #       auth = create(:authentication, slack_team_domain: nil)
  #       expect(auth.slack_team_ethereum_enabled?).to eq false
  #     end
  #   end
  # end

  describe '.find_or_create_from_auth_hash' do
    let(:auth_hash) do
      {
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

    context 'when nothing changed from last login' do
      it 'updates the timestamp on the authentications' do
        travel_to Date.new 2015
        account = described_class.find_or_create_from_auth_hash!(auth_hash)
        travel_to Date.new 2016
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.to change { account.slack_auth.reload.updated_at }
      end
    end

    context 'when no account exists yet' do
      it 'creates an account and authentications for that account' do
        account = described_class.find_or_create_from_auth_hash!(auth_hash)

        expect(account.email).to eq('bob@example.com')

        auth = account.authentications.first

        expect(auth.provider).to eq('slack')
        expect(account.first_name).to eq('Bob')
        expect(account.last_name).to eq('Roberts')
        expect(auth.uid).to eq('slack user id')
        expect(auth.token).to eq('xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa')
        expect(auth.oauth_response).to eq(auth_hash)
      end
    end

    context 'when there are missing credentials' do
      it 'blows up' do
        expect do
          expect do
            expect do
              described_class.find_or_create_from_auth_hash!({})
            end.to raise_error(SlackAuthHash::MissingAuthParamException)
          end.not_to change { Account.count }
        end.not_to change { described_class.count }
      end
    end

    context 'when there is a related account' do
      let!(:account) { create(:account, email: 'bob@example.com') }
      let!(:authentication) do
        create(:authentication,
          account_id: account.id,
          provider: 'slack',
          uid: 'slack user id',
          token: 'slack token')
      end

      it 'returns the existing account' do
        result = nil
        expect do
          expect do
            result = described_class.find_or_create_from_auth_hash!(auth_hash)
          end.not_to change { Account.count }
        end.not_to change { described_class.count }

        expect(result.id).to eq(account.id)
      end
    end
  end
end
