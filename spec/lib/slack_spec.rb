require 'rails_helper'

describe Comakery::Slack do
  let!(:team) { create :team }
  let!(:recipient) { create(:account, first_name: 'newt', last_name: 'newt') }
  let!(:recipient_authentication) { create(:authentication, account: recipient) }
  let!(:issuer) { create :account, first_name: 'jim', last_name: 'jim' }
  let!(:issuer_authentication) { create :authentication, account: issuer, token: 'xyz' }
  let!(:recipient_authentication) { create :authentication, account: recipient, token: 'abc' }
  let!(:project) { create :project }
  let!(:channel) { create :channel, project: project, team: team, name: 'super sweet slack channel' }
  let!(:award_type) { create :award_type, project: project }
  let!(:award) { create :award, channel: channel, award_type: award_type, issuer: issuer, account: recipient, quantity: 2 }
  let!(:message) { AwardMessage.call(award: award).notifications_message }
  let!(:slack) { described_class.new(slack_token) }
  let!(:slack_token) { issuer_authentication.token }

  before do
    team.build_authentication_team issuer_authentication
    team.build_authentication_team recipient_authentication
  end

  describe '#send_award_notifications' do
    it 'sends a notification to Slack with correct params' do
      stub_request(:post, 'https://slack.com/api/chat.postMessage').with(body: hash_including(text: message,
                                                                                              token: slack_token,
                                                                                              channel: "##{channel.name}",
                                                                                              username: / Bot/,
                                                                                              icon_url: Comakery::Slack::AVATAR,
                                                                                              as_user: 'false',
                                                                                              link_names: '1')).to_return(body: {
                                                                                                ok: true,
                                                                                                channel: 'channel id',
                                                                                                message: { ts: 'this is a timestamp' }
                                                                                              }.to_json)

      stub_request(:post, 'https://slack.com/api/reactions.add').with(body: hash_including(channel: 'channel id',
                                                                                           timestamp: 'this is a timestamp',
                                                                                           name: 'thumbsup')).to_return(body: { ok: true }.to_json)

      slack.send_award_notifications(award: award)
    end
  end

  describe '#award_notifications_message' do
    describe 'when the issuer sends to someone else' do
      it 'is from issuer to recipient' do
        expect(message).to match /@jim jim sent @newt newt a 2674.0 token Contribution/
      end
    end

    describe 'when the issuer sends to themselves' do
      before { award.update! account: issuer }
      it 'is self-issued' do
        message = AwardMessage.call(award: award).notifications_message
        expect(message).to match /@jim jim self-issued/
      end
    end

    describe 'when the award has a description' do
      it 'includes award description' do
        expect(message).to match /for "Great work"/
      end
    end

    describe 'when the award has no description' do
      before { award.update! description: '' }
      it 'includes award description' do
        message = AwardMessage.call(award: award).notifications_message
        expect(message).not_to match /for ".*"/m
      end
    end

    it 'links to the project' do
      expect(message).to match %r{<https?://localhost:3000/projects/#{project.id}\|Uber for Cats> project}
    end

    describe 'when project is ethereum enabled and recipient has no ethereum address' do
      it 'links to recipient account' do
        project.token.update! ethereum_enabled: true
        recipient.update! ethereum_wallet: nil
        message = AwardMessage.call(award: award.reload).notifications_message
        expect(message).to match \
          %r{<https?://localhost:3000/account\|Set up your account> to receive Ethereum tokens\.}
      end
    end

    describe 'when project is not ethereum enabled' do
      it 'does not link to recipient account' do
        project.token.update! ethereum_enabled: false
        recipient.update! ethereum_wallet: nil
        message = AwardMessage.call(award: award).notifications_message
        expect(message).not_to match %r{/account}
      end
    end

    describe 'when recipient has ethereum address' do
      it 'does not link to recipient account' do
        project.token.update! ethereum_enabled: true
        recipient.update! ethereum_wallet: '0x' + 'a' * 40
        message = AwardMessage.call(award: award).notifications_message
        expect(message).not_to match %r{/account}
      end
    end
  end

  describe '#get_users' do
    it 'returns the list of users in the slack instance' do
      stub_request(:post, 'https://slack.com/api/users.list')
        .with(body: { "token": 'token' }, headers: { 'Accept': 'application/json; charset=utf-8' })
        .to_return(body: File.read(Rails.root.join('spec/fixtures/users_list_response.json')))

      response = described_class.new('token').get_users

      expect(response.members[0][:name]).to eq('bobjohnson')
    end
  end

  describe '#get_user_info' do
    it 'returns the list of users in the slack instance' do
      stub_request(:post, 'https://slack.com/api/users.info')
        .with(body: { 'token' => 'token', 'user' => 'foobar' })
        .to_return(body: File.read(Rails.root.join('spec/fixtures/users_info_response.json')))

      response = described_class.new('token').get_user_info('foobar')

      expect(response[:user][:profile][:email]).to eq('glenn@example.com')
      expect(response[:user][:id]).to eq('U99M9QYFQ')
      expect(response[:user][:name]).to eq('glenn')
      expect(response[:user][:team_id]).to eq('T9999S99P')
    end
  end

  describe '#fetch_channels' do
    it 'returns the list of channels in the slack instance' do
      stub_request(:post, 'https://slack.com/api/channels.list')
        .with(body: { 'token' => 'token' })
        .to_return(body: File.read(Rails.root.join('spec', 'fixtures', 'channel_list_response.json')))

      response = described_class.new('token').fetch_channels

      expect(response['channels'][0]['id']).to eq('C000BE01L')
      expect(response['channels'][0]['name']).to eq('fun')
    end
  end
end
