require 'rails_helper'

describe Comakery::Slack do
  let!(:recipient) { create(:account) }
  let!(:recipient_authentication) { create(:authentication, account: recipient) }
  let!(:sender_authentication) { create :authentication, slack_token: 'xyz', slack_team_id: 'a team' }
  let!(:recipient_authentication) { create :authentication, account: recipient, slack_user_name: 'newt', slack_token: 'abc', slack_team_id: 'a team' }
  let!(:project) { create :project, slack_team_id: 'a team', slack_channel: 'super sweet slack channel' }
  let!(:award_type) { create :award_type, project: project }
  let!(:award) { create :award, award_type: award_type, authentication: recipient_authentication }
  let!(:slack) { Comakery::Slack.new(sender_authentication.slack_token) }

  describe '#send_award_notifications' do
    it 'should send a notification to Slack with correct params' do
      expected_text = "@newt received a 1337 coin Contribution for \"Great work\" on the <http://localhost:3000/projects/#{project.id}|Uber for Cats> project."
      stub_request(:post, "https://slack.com/api/chat.postMessage").
          with(body: hash_including({text: expected_text, token: "token", channel: "#super sweet slack channel", username: "CoMakery Bot", icon_url: Comakery::Slack::AVATAR, as_user: "false", link_names: "1"})).
          to_return(body: {ok: true, channel: "channel id", message: {ts: 'this is a timestamp'}}.to_json)

      stub_request(:post, "https://slack.com/api/reactions.add").
          with(body: hash_including({channel: "channel id", timestamp: "this is a timestamp", name: 'thumbsup'})).
          to_return(body: {ok: true}.to_json)

      Comakery::Slack.new("token").send_award_notifications(award: award)
    end
  end

  describe "#get_users" do
    it "returns the list of users in the slack instance" do
      stub_request(:post, "https://slack.com/api/users.list").
          with(body: {"token": "token"}, headers: {'Accept': 'application/json; charset=utf-8'}).
          to_return(body: File.read(Rails.root.join("spec/fixtures/users_list_response.json")))

      response = Comakery::Slack.new("token").get_users

      expect(response.members[0][:name]).to eq("bobjohnson")
    end
  end

  describe "#get_user_info" do
    it "returns the list of users in the slack instance" do
      stub_request(:post, "https://slack.com/api/users.info").
          with(body: {"token" => "token", "user" => "foobar"}).
          to_return(body: File.read(Rails.root.join("spec/fixtures/users_info_response.json")))

      response = Comakery::Slack.new("token").get_user_info("foobar")

      expect(response[:user][:profile][:email]).to eq("glenn@example.com")
      expect(response[:user][:id]).to eq("U99M9QYFQ")
      expect(response[:user][:name]).to eq("glenn")
      expect(response[:user][:team_id]).to eq("T9999S99P")
    end
  end

  describe "#get_channels" do
    it "returns the list of channels in the slack instance" do
      stub_request(:post, "https://slack.com/api/channels.list").
          with(body: {"token" => "token"}).
          to_return(body: File.read(Rails.root.join("spec", "fixtures", "channel_list_response.json")))

      response = Comakery::Slack.new("token").get_channels

      expect(response['channels'][0]["id"]).to eq("C000BE01L")
      expect(response['channels'][0]["name"]).to eq("fun")
    end
  end
end
