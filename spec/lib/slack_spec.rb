require 'rails_helper'

describe Swarmbot::Slack, :vcr do
  let!(:recipient) { create :account }
  let!(:sender_authentication) { create :authentication, slack_token: 'xyz', slack_team_id: 'a team' }
  let!(:recipient_authentication) { create :authentication, account: recipient, slack_token: 'abc', slack_team_id: 'a team' }
  let!(:project) { create :project, slack_team_id: 'a team' }
  let!(:reward_type) { create :reward_type, project: project }
  let!(:reward) { create :reward, reward_type: reward_type, account: recipient }
  let!(:slack) { Swarmbot::Slack.new(sender_authentication.slack_token) }

  describe '#send_reward_notifications' do
    it 'should send a notification to Slack with correct params' do
      expected_text = "John Doe received a 1337 coin Contribution for \"Great work\" on the <http://localhost:3000/projects/#{project.id}|Uber for Cats> project."
      stub_request(:post, "https://slack.com/api/chat.postMessage").
          # with(body: hash_including({text: expected_text, token: "token", channel: "#bot-testing", username: "swarmbot", icon_url: Swarmbot::Slack::AVATAR, as_user: "false"})).
          with(body: hash_including({text: expected_text, token: "token", channel: "#bot-testing", username: "swarmbot", icon_url: Swarmbot::Slack::AVATAR, as_user: "false"})).
          to_return(status: 200, body: {ok: true, channel: "channel id", message: {ts: 'this is a timestamp'}}.to_json)

      stub_request(:post, "https://slack.com/api/reactions.add").
          with(body: hash_including({channel: "channel id", timestamp: "this is a timestamp", name: 'thumbsup'})).
          to_return(status: 200, body: {ok: true}.to_json)

      Swarmbot::Slack.new("token").send_reward_notifications(reward: reward)
    end
  end

  describe "#get_users" do
    it "returns the list of users in the slack instance" do
      stub_request(:post, "https://slack.com/api/users.list").
          with(body: {"token": "token"}, headers: {'Accept': 'application/json; charset=utf-8'}).
          to_return(status: 200, body: File.read(Rails.root.join("spec/fixtures/users_list_response.json")), headers: {})

      response = Swarmbot::Slack.new("token").get_users

      expect(response[0][:name]).to eq("bobjohnson")
    end
  end

  describe "#get_users" do
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
