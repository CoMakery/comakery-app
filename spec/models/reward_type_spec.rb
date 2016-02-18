require 'rails_helper'

describe RewardType do
  describe "associations" do
    it "belongs to a project" do
      project = create(:project)
      reward_type = RewardType.create!(project: project, name: "Bob", suggested_amount: 6)
      expect(reward_type.project).to eq(project)
    end
  end
end
