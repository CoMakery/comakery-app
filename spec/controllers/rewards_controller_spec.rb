require 'rails_helper'

describe RewardsController do
  let(:issuer) { create(:account, name: "Issuer").tap { |a| create(:authentication, slack_team_id: "foo", account: a) } }
  let!(:receiver_account) { create(:account, name: "Receiver").tap { |a| create(:authentication, slack_team_id: "foo", account: a) } }
  let!(:other_account) { create(:account, name: "Other").tap { |a| create(:authentication, slack_team_id: "foo", account: a) } }
  let!(:different_team_account) { create(:account, name: "Other").tap { |a| create(:authentication, slack_team_id: "bar", account: a) } }

  let(:project) { create(:project, owner_account: issuer) }

  before { login(issuer) }

  describe "#create" do
    let(:reward_type) { create(:reward_type, project: project) }

    xit "launches missiles if you specify a reward type that doesn't belong to a project" do
      expect_any_instance_of(Account).not_to receive(:send_reward_notifications)

      expect do
        post :create, project_id: project.to_param, reward: {
                        account_id: receiver_account.id,
                        reward_type_id: create(:reward_type, amount: 1000000000, project: create(:project, slack_team_id: "hackerz")).to_param,
                        description: "I am teh haxor"
                    }
        expect(response.status).to eq(200)
      end.not_to change { project.rewards.count }
    end

    it "records a reward being created" do
      expect_any_instance_of(Account).to receive(:send_reward_notifications)
      expect do
        post :create, project_id: project.to_param, reward: {
                        account_id: receiver_account.id,
                        reward_type_id: reward_type.to_param,
                        description: "This rocks!!11"
                    }
        expect(response.status).to eq(302)
      end.to change { project.rewards.count }.by(1)

      expect(response).to redirect_to(project_path(project))
      expect(flash[:notice]).to eq("Successfully sent reward to Receiver")

      reward = Reward.last
      expect(reward.reward_type).to eq(reward_type)
      expect(reward.account).to eq(receiver_account)
      expect(reward.issuer).to eq(issuer)
      expect(reward.description).to eq("This rocks!!11")
    end
  end
end
