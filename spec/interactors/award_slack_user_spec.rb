require 'rails_helper'

describe AwardSlackUser do
  let!(:issuer) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "team id", slack_token: "token") } }
  let!(:project) { create(:project, owner_account: issuer, slack_team_id: "team id") }
  let!(:award_type) { create(:award_type, project: project) }

  let(:recipient) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "team id", slack_user_id: "recipient user id") } }

  context "when the account/auth exist already in the db" do
    it "builds a award for the given slack user id with the matching account from the db" do
      recipient
      result = nil
      expect do
        expect do
          expect do
            result = AwardSlackUser.call(issuer: issuer, slack_user_id: recipient.slack_auth.slack_user_id, award_params: {
                                                            award_type_id: award_type.to_param,
                                                            description: "This rocks!!11"
                                                        })
            expect(result.award).to be_a_new_record
            expect(result.award.award_type).to eq(award_type)
            expect(result.award.issuer).to eq(issuer)
            expect(result.award.account).to eq(recipient)
          end.not_to change { Award.count }
        end.not_to change { Authentication.count }
      end.not_to change { Account.count }
      expect(result.award.save).to eq(true)
    end

    context "when the award is not valid"
    it "fails with a nice message" do
      recipient
      expect do
        expect do
          expect do
            result = AwardSlackUser.call(issuer: issuer, slack_user_id: recipient.slack_auth.slack_user_id, award_params: {
                                                            award_type_id: nil,
                                                            description: "This rocks!!11"
                                                        })
            expect(result).not_to be_success
            expect(result.message).to eq("Award type can't be blank")
          end.not_to change { Award.count }
        end.not_to change { Authentication.count }
      end.not_to change { Account.count }
    end
  end

  context "when the slack user id is missing" do
    it "fails" do
      result = AwardSlackUser.call(slack_user_id: "", issuer: issuer)
      expect(result).not_to be_success
    end
  end

  context "when the account/auth don't exist yet" do
    it "fetches the user from slack and creates the account, auth, and returns the award" do
      stub_request(:post, "https://slack.com/api/users.info").
          with(body: {"token" => "token", "user" => "U99M9QYFQ"}).
          to_return(status: 200, body: File.read(Rails.root.join("spec/fixtures/users_info_response.json")), headers: {})

      result = nil
      expect do
        expect do
          expect do
            result = AwardSlackUser.call(issuer: issuer, slack_user_id: "U99M9QYFQ", award_params: {
                                                            award_type_id: award_type.to_param,
                                                            description: "This rocks!!11"
                                                        })
            expect(result.award).to be_a_new_record
            expect(result.award.award_type).to eq(award_type)
            expect(result.award.issuer).to eq(issuer)
            expect(result.award.account).to eq(Account.last)
          end.not_to change { Award.count }
        end.to change { Authentication.count }.by(1)
      end.to change { Account.count }.by(1)
      expect(result.award.save).to eq(true)
      expect(result.award.reload.account).to eq(Account.last)
    end
  end
end
