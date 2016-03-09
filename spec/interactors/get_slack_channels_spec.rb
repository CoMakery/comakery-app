require 'rails_helper'

describe GetSlackChannels do
  let(:current_account) { create(:account).tap{|a| create(:authentication, account: a)} }

  before do
    stub_request(:post, "https://slack.com/api/channels.list").to_return(body: File.read(Rails.root.join("spec","fixtures","channel_list_response.json")))
  end

  describe "#call" do
    it "returns a list of channels with their ids, excluding archived channels, sorted by number of users desc" do
      result = GetSlackChannels.call(current_account: current_account)
      expect(result.channels).to eq(["huge_channel", "fun", "boring_channel"])
    end
  end
end