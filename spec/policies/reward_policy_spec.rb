require 'rails_helper'

describe RewardPolicy do
  let(:account) { create(:account) }
  let(:other_account) { create(:account) }
  let(:project) { create(:project, owner_account: account) }

  let(:reward_without_project) { build(:reward) }
  let(:unowned_project) { create(:project, owner_account: other_account) }
  let(:reward_for_unowned_project) { build(:reward, project: unowned_project)}
  let(:reward_with_project) { build(:reward, project: project) }

  describe "new?" do
    it "returns true for errbody" do
      expect(RewardPolicy.new(nil, reward_without_project).new?).to be false
      expect(RewardPolicy.new(account, reward_without_project).new?).to be false
      expect(RewardPolicy.new(account, reward_for_unowned_project).new?).to be false
      expect(RewardPolicy.new(account, reward_with_project).new?).to be true
    end
  end
end
