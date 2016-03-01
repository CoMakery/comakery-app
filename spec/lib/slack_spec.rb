require 'rails_helper'

describe Swarmbot::Slack do
  let!(:recipient) { create :account }
  let!(:sender_authentication) { create :authentication, slack_token: 'xyz', slack_team_id: 'a team' }
  let!(:recipient_authentication) { create :authentication, account: recipient, slack_token: 'abc', slack_team_id: 'a team' }
  let!(:project) { create :project, slack_team_id: 'a team' }
  let!(:reward_type) { create :reward_type, project: project }
  let!(:reward) { create :reward, reward_type: reward_type, account: recipient }
  let!(:slack) { Swarmbot::Slack.new(sender_authentication.slack_token) }

  describe '.initialize' do
    it 'should create a new client' do
      allow(Slack::Web::Client).to receive(:new).and_return('the client')
      slack = Swarmbot::Slack.new(sender_authentication.slack_token)
      expect(Slack::Web::Client).to have_received(:new).with(hash_including(token: 'xyz'))
      expect(slack.instance_variable_get(:@client)).to eq('the client')
    end
  end

  describe '#send_reward_notifications' do
    it 'should send a notification to Slack' do
      client = slack.instance_variable_get(:@client)
      allow(client).to receive(:chat_postMessage) { {channel: 'C001', message: { ts: '1234' } } }
      allow(client).to receive(:reactions_add)
      slack.send_reward_notifications(reward: reward)
      expect(client).to have_received(:chat_postMessage)
      expect(client).to have_received(:reactions_add).with({ channel: 'C001', timestamp: '1234', name: 'thumbsup' })
    end
  end
end
