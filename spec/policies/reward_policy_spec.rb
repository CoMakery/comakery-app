require 'rails_helper'

describe RewardPolicy do
  let(:account) { create(:account) }
  let(:other_account) { create(:account) }
  let(:project) { create(:project, owner_account: account) }

  let(:reward_without_reward_type) { build(:reward, reward_type: nil) }
  let(:unowned_project) { create(:project, owner_account: other_account) }
  let(:reward_type_for_unowned_project) { create(:reward_type, project: unowned_project)}
  let(:reward_for_unowned_project) { build(:reward, reward_type: reward_type_for_unowned_project)}
  let(:reward_type_with_project) { create(:reward_type, project: project) }
  let(:reward_with_project) { build(:reward, reward_type: reward_type_with_project) }

  describe "create?" do
    it "returns true for errbody" do
      expect(RewardPolicy.new(nil, reward_without_reward_type).create?).to be_falsey
      expect(RewardPolicy.new(account, reward_without_reward_type).create?).to be false
      expect(RewardPolicy.new(account, reward_for_unowned_project).create?).to be false
      expect(RewardPolicy.new(account, reward_with_project).create?).to be true
    end

    it "returns false when the rewardee doesn't belong to the project"
    it "returns false when the reward_type doesn't belong to the project"
    it "returns false when the issuer doesn't belong to the project"
  end
end
