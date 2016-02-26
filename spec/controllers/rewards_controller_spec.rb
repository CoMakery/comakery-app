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

    it "records a reward being created" do
      request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

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

    it "renders error if you specify a reward type that doesn't belong to a project" do
      expect_any_instance_of(Account).not_to receive(:send_reward_notifications)
      request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

      expect do
        post :create, project_id: project.to_param, reward: {
                        account_id: receiver_account.id,
                        reward_type_id: create(:reward_type, amount: 1000000000, project: create(:project, slack_team_id: "hackerz")).to_param,
                        description: "I am teh haxor"
                    }
        expect(response.status).to eq(302)
      end.not_to change { project.rewards.count }
      expect(flash[:error]).to eq("Failed sending reward")
    end

    it "redirects back to projects show if error saving" do
      expect do
        request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

        post :create, project_id: project.to_param, reward: {
                        account_id: receiver_account.id,
                        description: "This rocks!!11"
                    }
        expect(response.status).to eq(302)
      end.not_to change { project.rewards.count }

      expect(response).to redirect_to(project_path(project))
      expect(flash[:error]).to eq("Failed sending reward")
    end
  end
end
