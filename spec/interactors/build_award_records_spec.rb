require 'rails_helper'

describe BuildAwardRecords do
  let!(:team) { create :team }
  let!(:authentication) { create :authentication }
  let!(:issuer) { authentication.account }
  let!(:other_auth) { create(:authentication, account: issuer, token: 'token') }
  let!(:project) { create(:project, account: issuer) }
  let!(:other_project) { create(:project, account: create(:account)) }
  let!(:award_type) { create(:award_type, project: project) }

  let(:recipient) { create(:account, email: 'glenn@example.com') }
  let(:recipient_authentication) { create(:authentication, account: recipient) }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team recipient_authentication
    project.channels.create(team: team, channel_id: 'channel_id', name: 'slack_channel')
  end

  context 'when the account/auth exists already in the db' do
    it 'builds a award for the given slack user id with the matching account from the db' do
      recipient
      recipient_authentication
      result = nil
      expect do
        expect do
          expect do
            result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {
              description: 'This rocks!!11',
              uid: recipient_authentication.uid
            }, total_tokens_issued: 0)
            expect(result).to be_success
            expect(result.award).to be_a_new_record
            expect(result.award.award_type).to eq(award_type)
            expect(result.award.account).to eq(recipient)
          end.not_to change { Award.count }
        end.not_to change { Authentication.count }
      end.not_to change { Account.count }
      expect(result.award.save).to eq(true)
    end

    it 'when award type is not community_awardable' do
      recipient
      recipient_authentication
      award_type.update community_awardable: false

      result = described_class.call(project: project, issuer: create(:account), award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {
        description: 'This rocks!!11',
        uid: recipient_authentication.uid
      }, total_tokens_issued: 0)
      expect(result).not_to be_success
      expect(result.message).to eq 'Not authorized'
    end

    context 'when the award is not valid because of bad award type' do
      it 'fails with a nice message' do
        recipient
        recipient_authentication
        expect do
          expect do
            expect do
              result = described_class.call(project: project, issuer: issuer, channel_id: project.channels.first.id, award_params: {
                award_type_id: nil,
                description: 'This rocks!!11',
                uid: recipient_authentication.uid
              }, total_tokens_issued: 0)
              expect(result).not_to be_success
              expect(result.message).to eq('missing award type')
            end.not_to change { Award.count }
          end.not_to change { Authentication.count }
        end.not_to change { Account.count }
      end
    end
  end

  context 'when the project has already awarded the maximum amount of awards' do
    it 'returns an error message without creating the award' do
      recipient
      recipient_authentication
      award_type.update!(amount: project.maximum_tokens + 1)

      expect do
        result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {
          award_type_id: award_type.to_param,
          uid: recipient_authentication.uid
        }, total_tokens_issued: 0)
        expect(result).not_to be_success
        expect(result.message).to eq("Sorry, you can't send more awards than the project's maximum number of allowable tokens")
      end.not_to change { Award.count }
    end

    it 'raises based on award.total_amount with multiple award unit quantity' do
      recipient
      recipient_authentication
      award_type.update(amount: 1)
      expect do
        result = described_class.call(project: project, issuer: issuer, channel_id: project.channels.first.id, award_type_id: award_type.to_param,
                                      award_params: {
                                        quantity: 2,
                                        uid: recipient_authentication.uid
                                      },
                                      total_tokens_issued: project.maximum_tokens - 1)

        expect(result).not_to be_success
        expect(result.message).to eq("Sorry, you can't send more awards than the project's maximum number of allowable tokens")
      end.not_to change { Award.count }
    end
  end

  context 'when the uid is missing' do
    it 'fails' do
      result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {}, total_tokens_issued: 0)
      expect(result).not_to be_success
    end
  end

  context "when the auth doesn't exist yet" do
    context 'when the account exists already in the db' do
      it 'creates the auth, and returns the award' do
        recipient
        stub_request(:post, 'https://slack.com/api/users.info')
          .with(body: { 'token' => 'slack token', 'user' => 'U99M9QYFQ_other' },
                headers: { 'Accept' => 'application/json; charset=utf-8', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Slack Ruby Client/0.11.0' })
          .to_return(status: 200, body: File.read(Rails.root.join('spec/fixtures/users_info_response.json')), headers: {})

        result = nil
        expect do
          expect do
            expect do
              result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {
                description: 'This rocks!!11',
                uid: 'U99M9QYFQ_other'
              }, total_tokens_issued: 0)
              expect(result.message).to be_nil
              expect(result.award).to be_a_new_record
              expect(result.award.award_type).to eq(award_type)
            end.not_to change { Award.count }
          end.to change { Authentication.count }.by(1)
        end.not_to change { Account.count }
        expect(result.award.save).to eq(true)
      end
    end
  end

  context "when the account doesn't exist yet" do
    before do
      stub_request(:post, 'https://slack.com/api/users.info')
        .with(body: { 'token' => 'slack token', 'user' => 'U99M9QYFQ' })
        .to_return(status: 200, body: File.read(Rails.root.join('spec/fixtures/users_info_response.json')), headers: {})
        recipient.destroy
    end

    it 'creates the auth with the slack details from the project' do
      expect do
        result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {
          description: 'This rocks!!11',
          uid: 'U99M9QYFQ'
        }, total_tokens_issued: 0)
        expect(result.message).to be_nil
      end.to change { Authentication.count }.by(1)
      created_account = Account.last
      expect(created_account.teams.last).to eq team
    end

    it 'fetches the user from slack and creates the account, auth, and returns the award' do
      result = nil
      expect do
        expect do
          result = described_class.call(project: project, issuer: issuer, award_type_id: award_type.to_param, channel_id: project.channels.first.id, award_params: {
            award_type_id: award_type.to_param,
            description: 'This rocks!!11',
            uid: 'U99M9QYFQ',
            channel_id: project.channels.last.id
          }, total_tokens_issued: 0)
          expect(result.message).to be_nil
          expect(result.award).to be_a_new_record
          expect(result.award.award_type).to eq(award_type)
          expect(result.award.account).to eq(Account.last)
        end.not_to change { Award.count }
      end.to change { Account.count }.by(1)
      expect(result.award.save).to eq(true)
    end
  end
end
