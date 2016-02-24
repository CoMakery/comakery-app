require 'rails_helper'

describe RewardsController do
  let(:issuer) { create(:account, name: "Issuer").tap{|a|create(:authentication, slack_team_id: "foo", account: a) } }
  let!(:receiver_account) { create(:account, name: "Receiver").tap{|a|create(:authentication, slack_team_id: "foo", account: a)} }
  let!(:other_account) { create(:account, name: "Other").tap{|a|create(:authentication, slack_team_id: "foo", account: a)} }
  let!(:different_team_account) { create(:account, name: "Other").tap{|a|create(:authentication, slack_team_id: "bar", account: a)} }
  let(:project) { create(:project, owner_account: issuer) }

  before { login(issuer) }

  describe "#new" do
    it "renders and shows accounts that can be rewarded not including the current account" do
      get :new, project_id: project.to_param

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
      expect(assigns[:reward]).to be_new_record
      expect(assigns[:rewardable_accounts].map(&:name).sort).to eq([issuer.name, other_account.name, receiver_account.name])
    end
  end

  describe "#create" do
    it "records a reward being created" do
      expect do
        post :create, project_id: project.to_param, reward: {
                        account_id: receiver_account.id,
                        amount: 3000,
                        issuer: issuer,
                        description: "This rocks!!11"
                    }
        expect(response.status).to eq(302)
      end.to change { project.rewards.count }.by(1)

      expect(response).to redirect_to(project_path(project))
      expect(flash[:notice]).to eq("Successfully sent reward to Receiver")

      reward = Reward.last
      expect(reward.project).to eq(project)
      expect(reward.account).to eq(receiver_account)
      expect(reward.issuer).to eq(issuer)
      expect(reward.amount).to eq(3000)
      expect(reward.description).to eq("This rocks!!11")
    end
  end
end
