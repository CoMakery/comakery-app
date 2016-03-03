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
      allow(client).to receive(:chat_postMessage) { {channel: 'C001', message: {ts: '1234'}} }
      allow(client).to receive(:reactions_add)
      slack.send_reward_notifications(reward: reward)
      expect(client).to have_received(:chat_postMessage)
      expect(client).to have_received(:reactions_add).with({channel: 'C001', timestamp: '1234', name: 'thumbsup'})
    end
  end

  describe "#get_users", :vcr do
    it "returns the list of users in the slack instance" do
      stub_request(:post, "https://slack.com/api/users.list").
          with(body: {"token": "token"}, headers: {'Accept': 'application/json; charset=utf-8'}).
          to_return(status: 200, body: File.read(Rails.root.join("spec/fixtures/users_list_response.json")), headers: {})

      response = Swarmbot::Slack.new("token").get_users

      expect(response[0][:name]).to eq("bobjohnson")
    end
  end

  describe "#get_users", :vcr do
    it "returns the list of users in the slack instance" do
      stub_request(:post, "https://slack.com/api/users.info").
        with(body: {"token" => "token", "user" => "foobar"}).
        to_return(status: 200, body: File.read(Rails.root.join("spec/fixtures/users_info_response.json")), headers: {})

      response = Swarmbot::Slack.new("token").get_user_info("foobar")

      expect(response[:profile][:email]).to eq("glenn@example.com")
      expect(response[:id]).to eq("U99M9QYFQ")
      expect(response[:name]).to eq("glenn")
      expect(response[:team_id]).to eq("T9999S99P")
    end
  end
end
