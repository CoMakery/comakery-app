require 'rails_helper'

describe RewardSlackUser do
  let!(:issuer) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "team id", slack_token: "token") } }
  let!(:project) { create(:project, owner_account: issuer, slack_team_id: "team id") }
  let!(:reward_type) { create(:reward_type, project: project) }

  let(:recipient) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "team id", slack_user_id: "recipient user id") } }

  context "when the account/auth exist already in the db" do
    it "builds a reward for the given slack user id with the matching account from the db" do
      recipient
      result = nil
      expect do
        expect do
          expect do
            result = RewardSlackUser.call(issuer: issuer, slack_user_id: recipient.slack_auth.slack_user_id, reward_params: {
                                                            reward_type_id: reward_type.to_param,
                                                            description: "This rocks!!11"
                                                        })
            expect(result.reward).to be_a_new_record
            expect(result.reward.reward_type).to eq(reward_type)
            expect(result.reward.issuer).to eq(issuer)
            expect(result.reward.account).to eq(recipient)
          end.not_to change { Reward.count }
        end.not_to change { Authentication.count }
      end.not_to change { Account.count }
      expect(result.reward.save).to eq(true)
    end

    context "when the reward is not valid"
    it "fails with a nice message" do
      recipient
      expect do
        expect do
          expect do
            result = RewardSlackUser.call(issuer: issuer, slack_user_id: recipient.slack_auth.slack_user_id, reward_params: {
                                                            reward_type_id: nil,
                                                            description: "This rocks!!11"
                                                        })
            expect(result).not_to be_success
            expect(result.message).to eq("Reward type can't be blank")
          end.not_to change { Reward.count }
        end.not_to change { Authentication.count }
      end.not_to change { Account.count }
    end
  end

  context "when the slack user id is missing" do
    it "fails" do
      result = RewardSlackUser.call(slack_user_id: "", issuer: issuer)
      expect(result).not_to be_success
    end
  end

  context "when the account/auth don't exist yet" do
    it "fetches the user from slack and creates the account, auth, and returns the reward" do
      stub_request(:post, "https://slack.com/api/users.info").
          with(body: {"token" => "token", "user" => "U99M9QYFQ"}).
          to_return(status: 200, body: File.read(Rails.root.join("spec/fixtures/users_info_response.json")), headers: {})

      result = nil
      expect do
        expect do
          expect do
            result = RewardSlackUser.call(issuer: issuer, slack_user_id: "U99M9QYFQ", reward_params: {
                                                            reward_type_id: reward_type.to_param,
                                                            description: "This rocks!!11"
                                                        })
            expect(result.reward).to be_a_new_record
            expect(result.reward.reward_type).to eq(reward_type)
            expect(result.reward.issuer).to eq(issuer)
            expect(result.reward.account).to eq(Account.last)
          end.not_to change { Reward.count }
        end.to change { Authentication.count }.by(1)
      end.to change { Account.count }.by(1)
      expect(result.reward.save).to eq(true)
      expect(result.reward.reload.account).to eq(Account.last)
    end
  end
end
