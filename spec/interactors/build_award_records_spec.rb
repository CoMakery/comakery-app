require 'rails_helper'

describe BuildAwardRecords do
  let!(:issuer) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: 'team id', slack_token: 'token') } }
  let!(:other_auth) { create(:authentication, account: issuer, slack_team_id: 'other team id', slack_token: 'token') }
  let!(:project) { create(:project, account: issuer, slack_team_id: 'team id') }
  let!(:other_project) { create(:project, account: issuer, slack_team_id: 'other team id') }
  let!(:award_type) { create(:award_type, project: project) }

  let(:recipient) { create(:account, email: 'glenn@example.com') }
  let(:recipient_authentication) { create(:authentication, account: recipient, slack_team_id: 'team id', slack_user_id: 'recipient user id') }

  context 'when the account/auth exists already in the db' do
    it 'builds a award for the given slack user id with the matching account from the db' do
      recipient
      recipient_authentication
      result = nil
      expect do
        expect do
          expect do
            result = described_class.call(project: project, issuer: issuer, slack_user_id: recipient_authentication.slack_user_id, award_params: {
              award_type_id: award_type.to_param,
              description: 'This rocks!!11'
            }, total_tokens_issued: 0)
            expect(result).to be_success
            expect(result.award).to be_a_new_record
            expect(result.award.award_type).to eq(award_type)
            expect(result.award.issuer).to eq(issuer)
            expect(result.award.authentication).to eq(recipient_authentication)
          end.not_to change { Award.count }
        end.not_to change { Authentication.count }
      end.not_to change { Account.count }
      expect(result.award.save).to eq(true)
    end

    context 'when the award is not valid' do
      it 'fails with a nice message' do
        recipient
        recipient_authentication
        expect do
          expect do
            expect do
              result = described_class.call(project: project, issuer: nil, slack_user_id: recipient.slack_auth.slack_user_id, award_params: {
                award_type_id: award_type.to_param,
                description: 'This rocks!!11'
              }, total_tokens_issued: 0)
              expect(result).not_to be_success
              expect(result.message).to eq("Issuer can't be blank")
            end.not_to change { Award.count }
          end.not_to change { Authentication.count }
        end.not_to change { Account.count }
      end
    end

    context 'when the award is not valid because of bad award type' do
      it 'fails with a nice message' do
        recipient
        recipient_authentication
        expect do
          expect do
            expect do
              result = described_class.call(project: project, issuer: issuer, slack_user_id: recipient.slack_auth.slack_user_id, award_params: {
                award_type_id: nil,
                description: 'This rocks!!11'
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
        result = described_class.call(project: project,
                                      issuer: issuer,
                                      slack_user_id: recipient_authentication.slack_user_id,
                                      award_params: { award_type_id: award_type.to_param },
                                      total_tokens_issued: 0)
        expect(result).not_to be_success
        expect(result.message).to eq("Sorry, you can't send more awards than the project's maximum number of allowable tokens")
      end.not_to change { Award.count }
    end

    it 'raises based on award.total_amount with multiple award unit quantity' do
      recipient
      recipient_authentication
      award_type.update(amount: 1)
      expect do
        result = described_class.call(project: project,
                                      issuer: issuer,
                                      slack_user_id: recipient_authentication.slack_user_id,
                                      award_params: { award_type_id: award_type.to_param,
                                                      quantity: 2 },
                                      total_tokens_issued: project.maximum_tokens - 1)

        expect(result).not_to be_success
        expect(result.message).to eq("Sorry, you can't send more awards than the project's maximum number of allowable tokens")
      end.not_to change { Award.count }
    end
  end

  context 'when the slack user id is missing' do
    it 'fails' do
      result = described_class.call(project: project, slack_user_id: '', issuer: issuer, total_tokens_issued: 0)
      expect(result).not_to be_success
    end
  end

  context "when the auth doesn't exist yet" do
    context 'when the account exists already in the db' do
      it 'creates the auth, and returns the award' do
        recipient
        stub_request(:post, 'https://slack.com/api/users.info')
          .with(body: { 'token' => 'token', 'user' => 'U99M9QYFQ' })
          .to_return(status: 200, body: File.read(Rails.root.join('spec/fixtures/users_info_response.json')), headers: {})

        result = nil
        expect do
          expect do
            expect do
              result = described_class.call(project: project, issuer: issuer, slack_user_id: 'U99M9QYFQ', award_params: {
                award_type_id: award_type.to_param,
                description: 'This rocks!!11'
              }, total_tokens_issued: 0)
              expect(result.message).to be_nil
              expect(result.award).to be_a_new_record
              expect(result.award.award_type).to eq(award_type)
              expect(result.award.issuer).to eq(issuer)
            end.not_to change { Award.count }
          end.to change { Authentication.count }.by(1)
        end.not_to change { Account.count }
        expect(result.award.save).to eq(true)
        expect(result.award.reload.authentication).to eq(recipient.authentications.last)
      end
    end
  end

  context "when the account doesn't exist yet" do
    before do
      stub_request(:post, 'https://slack.com/api/users.info')
        .with(body: { 'token' => 'token', 'user' => 'U99M9QYFQ' })
        .to_return(status: 200, body: File.read(Rails.root.join('spec/fixtures/users_info_response.json')), headers: {})
    end

    it 'creates the auth with the slack details from the project' do
      expect do
        result = described_class.call(project: project, issuer: issuer, slack_user_id: 'U99M9QYFQ', award_params: {
          award_type_id: award_type.to_param,
          description: 'This rocks!!11'
        }, total_tokens_issued: 0)
        expect(result.message).to be_nil
      end.to change { Authentication.count }.by(1)
      created_auth = Authentication.last
      expect(created_auth.slack_team_id).to eq(project.slack_team_id)
      expect(created_auth.slack_team_name).to eq(project.slack_team_name)
    end

    it 'fetches the user from slack and creates the account, auth, and returns the award' do
      result = nil
      expect do
        expect do
          result = described_class.call(project: project, issuer: issuer, slack_user_id: 'U99M9QYFQ', award_params: {
            award_type_id: award_type.to_param,
            description: 'This rocks!!11'
          }, total_tokens_issued: 0)
          expect(result.message).to be_nil
          expect(result.award).to be_a_new_record
          expect(result.award.award_type).to eq(award_type)
          expect(result.award.issuer).to eq(issuer)
          expect(result.award.authentication).to eq(Account.last.authentications.last)
        end.not_to change { Award.count }
      end.to change { Account.count }.by(1)
      expect(result.award.save).to eq(true)
      expect(result.award.reload.authentication).to eq(Account.last.authentications.last)
    end
  end
end
