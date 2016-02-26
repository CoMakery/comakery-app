require 'rails_helper'

describe RewardPolicy do
  let(:account) { create(:account) }
  let(:other_account) { create(:account) }
  let(:project) { create(:project, owner_account: account) }

  let(:reward_without_reward_type) {  }
  let(:unowned_project) { create(:project, owner_account: other_account) }
  let(:reward_type_for_unowned_project) { create(:reward_type, project: unowned_project)}
  let(:reward_for_unowned_project) { build(:reward, reward_type: reward_type_for_unowned_project)}
  let(:reward_type_with_project) { create(:reward_type, project: project) }
  let(:reward_with_project) { build(:reward, reward_type: reward_type_with_project) }

  describe "create?" do
    it "returns false when no account" do
      expect(RewardPolicy.new(nil, build(:reward, reward_type: nil)).create?).to be_falsey
    end

    it "returns false when reward doesn't have a reward_type" do
      expect(RewardPolicy.new(account, reward_without_reward_type).create?).to be false
    end

    it "returns false when the reward_type on the reward does not belong to the account's project" do
      expect(RewardPolicy.new(account, reward_for_unowned_project).create?).to be false
    end

    it "returns true when the accounts belongs to a project, and the reward belongs to a reward_type that belongs to that project" do
      expect(RewardPolicy.new(account, reward_with_project).create?).to be true
    end
  end
end
