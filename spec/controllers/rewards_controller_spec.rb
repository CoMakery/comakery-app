require 'rails_helper'

describe RewardsController do
  let(:issuer) { create(:account, email: "issuer@example.com").tap { |a| create(:authentication, slack_team_id: "foo", account: a, slack_user_id: 'issuer id') } }
  let!(:receiver_account) { create(:account, email: "receiver@example.com").tap { |a| create(:authentication, slack_team_id: "foo", slack_user_name: 'receiver', slack_user_id: 'receiver id', account: a) } }
  let!(:other_account) { create(:account, email: "other@example.com").tap { |a| create(:authentication, slack_team_id: "foo", account: a, slack_user_id: 'other id') } }
  let!(:different_team_account) { create(:account, email: "different@example.com").tap { |a| create(:authentication, slack_team_id: "bar", account: a, slack_user_id: 'different team member id') } }

  let(:project) { create(:project, owner_account: issuer, slack_team_id: "foo") }

  before { login(issuer) }

  describe "#index" do
    it "shows rewards for current project" do
      reward = create(:reward, reward_type: create(:reward_type, project: project), account: other_account, issuer: issuer)

      get :index, project_id: project.to_param

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
      expect(assigns[:rewards]).to match_array([reward])
    end
  end

  describe "#create" do
    let(:reward_type) { create(:reward_type, project: project) }

    it "records a reward being created" do
      request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

      expect_any_instance_of(Account).to receive(:send_reward_notifications)
      expect do
        post :create, project_id: project.to_param, reward: {
                        slack_user_id: receiver_account.slack_auth.slack_user_id,
                        reward_type_id: reward_type.to_param,
                        description: "This rocks!!11"
                    }
        expect(response.status).to eq(302)
      end.to change { project.rewards.count }.by(1)

      expect(response).to redirect_to(project_rewards_path(project))
      expect(flash[:notice]).to eq("Successfully sent reward to @receiver")

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
                        slack_user_id: "receiver id",
                        reward_type_id: create(:reward_type, amount: 1000000000, project: create(:project, slack_team_id: "hackerz")).to_param,
                        description: "I am teh haxor"
                    }
        expect(response.status).to eq(302)
      end.not_to change { project.rewards.count }
      expect(flash[:error]).to eq("Failed sending reward")
    end

    it "renders error if you specify a slack user id that doesn't belong to a project" do
      expect_any_instance_of(Account).not_to receive(:send_reward_notifications)
      request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

      expect do
        post :create, project_id: project.to_param, reward: {
                        slack_user_id: 'different team member id',
                        reward_type_id: reward_type.to_param,
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
                        slack_user_id: receiver_account.slack_auth.slack_user_id,
                        description: "This rocks!!11"
                    }
        expect(response.status).to eq(302)
      end.not_to change { project.rewards.count }

      expect(response).to redirect_to(project_path(project))
      expect(flash[:error]).to eq("Failed sending reward")
    end
  end
end
