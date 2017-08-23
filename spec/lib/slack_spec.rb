require 'rails_helper'

describe Comakery::Slack do
  let!(:recipient) { create(:account) }
  let!(:recipient_authentication) { create(:authentication, account: recipient) }
  let!(:issuer) { create :account }
  let!(:issuer_authentication) { create :authentication, account: issuer, slack_token: 'xyz', slack_user_name: 'jim', slack_team_id: 'a team' }
  let!(:recipient_authentication) { create :authentication, account: recipient, slack_user_name: 'newt', slack_token: 'abc', slack_team_id: 'a team' }
  let!(:project) { create :project, slack_team_id: 'a team', slack_channel: 'super sweet slack channel' }
  let!(:award_type) { create :award_type, project: project }
  let!(:award) { create :award, award_type: award_type, issuer: issuer, authentication: recipient_authentication, quantity: 2 }
  let!(:slack) { Comakery::Slack.new(slack_token) }
  let!(:slack_token) { issuer_authentication.slack_token }

  describe '#send_award_notifications' do
    it 'should send a notification to Slack with correct params' do
      stub_request(:post, "https://slack.com/api/chat.postMessage"
        ).with(body: hash_including({
          text: slack.award_notifications_message(award),
          token: slack_token,
          channel: "#super sweet slack channel",
          username: "CoMakery Bot",
          icon_url: Comakery::Slack::AVATAR,
          as_user: "false",
          link_names: "1"}
        )).to_return(body: {
          ok: true,
          channel: "channel id",
          message: {ts: 'this is a timestamp'}
        }.to_json)

      stub_request(:post, "https://slack.com/api/reactions.add"
        ).with(body: hash_including({
          channel: "channel id",
          timestamp: "this is a timestamp",
          name: 'thumbsup'
        })).to_return(body: {ok: true}.to_json)

      slack.send_award_notifications(award: award)
    end
  end

  describe '#award_notifications_message' do
    describe "when the issuer sends to someone else" do
      it 'should be from issuer to recipient' do
        message = slack.award_notifications_message(award)
        expect(message).to match %r{@jim sent @newt a 2674 token Contribution}
      end
    end

    describe "when the issuer sends to themselves" do
      before { award.update! authentication: issuer_authentication }
      it 'should be self-issued' do
        message = slack.award_notifications_message(award)
        expect(message).to match %r{@jim self-issued}
      end
    end

    describe "when the award has a description" do
      it 'should include award description' do
        message = slack.award_notifications_message(award)
        expect(message).to match %r{for "Great work"}
      end
    end

    describe "when the award has no description" do
      before { award.update! description: '' }
      it 'should include award description' do
        message = slack.award_notifications_message(award)
        expect(message).not_to match %r{for ".*"}m
      end
    end

    it 'should link to the project' do
      message = slack.award_notifications_message(award)
      expect(message).to match %r{<https://localhost:3000/projects/#{project.id}\|Uber for Cats> project}
    end

    describe "when project is ethereum enabled and recipient has no ethereum address" do
      it 'should link to recipient account' do
        project.update! ethereum_enabled: true
        recipient.update! ethereum_wallet: nil
        message = slack.award_notifications_message(award)
        expect(message).to match \
          %r{<https://localhost:3000/account\|Set up your account> to receive Ethereum tokens\.}
      end
    end

    describe "when project is not ethereum enabled" do
      it 'should not link to recipient account' do
        project.update! ethereum_enabled: false
        recipient.update! ethereum_wallet: nil
        message = slack.award_notifications_message(award)
        expect(message).not_to match %r{/account}
      end
    end

    describe "when recipient has ethereum address" do
      it 'should not link to recipient account' do
        project.update! ethereum_enabled: true
        recipient.update! ethereum_wallet: '0x'+'a'*40
        message = slack.award_notifications_message(award)
        expect(message).not_to match %r{/account}
      end
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
