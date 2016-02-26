require 'rails_helper'

describe Swarmbot::Slack do
  let (:authentication) { create :authentication, slack_token: 'xyz' }
  let (:project) { create :project }
  let (:reward) { create(:reward, reward_type: create(:reward_type, project: project)) }
  let(:slack) { Swarmbot::Slack.new(authentication) }

  describe '.initialize' do
    it 'should create a new client' do
      allow(Slack::Web::Client).to receive(:new).and_return('the client')
      slack = Swarmbot::Slack.new(authentication)
      expect(Slack::Web::Client).to have_received(:new).with(token: 'xyz')
      expect(slack.instance_variable_get(:@client)).to eq('the client')
    end
  end

  describe '#send_reward_notifications' do
    it 'should send a notification to Slack' do
      client = slack.instance_variable_get(:@client)
      allow(client).to receive(:chat_postMessage)
      slack.send_reward_notifications reward: reward
      expect(client).to have_received(:chat_postMessage)
    end
  end
end
