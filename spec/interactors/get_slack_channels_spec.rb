require 'rails_helper'

describe GetSlackChannels do
  let(:current_account) { create(:account).tap { |a| create(:authentication, account: a) } }

  context "on successful api call" do
    before do
      stub_request(:post, "https://slack.com/api/channels.list").to_return(body: File.read(Rails.root.join("spec", "fixtures", "channel_list_response.json")))
    end

    describe "#call" do
      it "returns a list of channels with their ids, excluding archived channels, sorted alphabetically" do
        result = GetSlackChannels.call(current_account: current_account)
        expect(result.channels).to eq(["boring_channel", "fun", "huge_channel"])
      end
    end
  end

  context "on failed api call" do
    before do
      stub_request(:post, "https://slack.com/api/channels.list").to_return(body: {ok: false}.to_json)
    end

    it "fails the interactor" do
      result = GetSlackChannels.call(current_account: current_account)
      expect(result).not_to be_success
      expect(result.message).to eq("Slack API error - Slack::Web::Api::Error")
    end
  end
end