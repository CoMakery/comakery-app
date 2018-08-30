require 'rails_helper'

describe GetSlackChannels do
  let(:team) { create :team }
  let(:account) { create(:account) }
  let(:authentication) { create(:authentication, account: account) }

  before do
    team.build_authentication_team authentication
  end

  context 'on successful api call' do
    before do
      stub_request(:post, 'https://slack.com/api/channels.list').to_return(body: File.read(Rails.root.join('spec', 'fixtures', 'channel_list_response.json')))
    end

    describe '#call' do
      it 'returns a list of channels with their ids, excluding archived channels, sorted alphabetically' do
        result = described_class.call(authentication_team: authentication.authentication_teams.last)
        expect(result.channels).to eq(%w[boring_channel fun huge_channel])
      end
    end
  end

  context 'on failed api call' do
    before do
      stub_request(:post, 'https://slack.com/api/channels.list').to_return(body: { ok: false, channels: [] }.to_json)
    end
    describe '#call' do
      it 'fails the interactor' do
        result = described_class.call(authentication_team: authentication.authentication_teams.last)
        expect(result).not_to be_success
        expect(result.message).to match(/Slack API error/)
      end
    end
  end
end
