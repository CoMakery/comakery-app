require 'rails_helper'

describe RewardPolicy do
  let(:project) { create(:project, owner_account: account) }
  let(:reward_type_with_project) { create(:reward_type, project: project) }
  let(:reward_with_project) { build(:reward, reward_type: reward_type_with_project, account: receiving_account) }
  let(:account) { create(:account) }
  let(:receiving_account) { create(:account).tap{|a|create(:authentication, account: a)} }

  let(:other_account) { create(:account).tap{|a| create(:authentication, slack_team_id: "other team")} }
  let(:unowned_project) { create(:project, owner_account: other_account) }

  let(:different_team_account) { create(:account) }

  let(:reward_type_for_unowned_project) { create(:reward_type, project: unowned_project)}
  let(:reward_for_unowned_project) { build(:reward, reward_type: reward_type_for_unowned_project)}


  describe "create?" do
    # sender account -> owner_account -> project <- reward_type <- reward <- receiver account

    it "returns true when the accounts belongs to a project, and the reward belongs to a reward_type that belongs to that project" do
      expect(RewardPolicy.new(account, reward_with_project).create?).to be true
    end

    it "returns false when no account" do
      expect(RewardPolicy.new(nil, build(:reward, reward_type: reward_type_with_project)).create?).to be_falsey
    end

    it "returns false when the sending account doesn't own the project" do
      expect(RewardPolicy.new(different_team_account, build(:reward, reward_type: reward_type_with_project, account: receiving_account)).create?).to be_falsey
    end

    it "returns false when the receiving account doesn't belong to the project" do
      expect(RewardPolicy.new(account, build(:reward, reward_type: reward_type_with_project, account: other_account)).create?).to be_falsey
    end

    it "returns false when reward doesn't have a reward_type" do
      expect(RewardPolicy.new(account, build(:reward, reward_type: nil)).create?).to be false
    end

    it "returns false when the reward_type on the reward does not belong to the account's project" do
      expect(RewardPolicy.new(account, reward_for_unowned_project).create?).to be false
    end
  end
end
