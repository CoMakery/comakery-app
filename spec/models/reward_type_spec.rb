require 'rails_helper'

describe RewardType do
  describe "#validations" do
    it "requires many attributes" do
      reward_type = RewardType.new
      expect(reward_type).not_to be_valid
      expect(reward_type.errors.full_messages).to eq(["Project can't be blank", "Name can't be blank", "Suggested amount can't be blank"])
    end
  end

  describe "associations" do
    it "belongs to a project" do
      project = create(:project)
      reward_type = RewardType.create!(project: project, name: "Bob", suggested_amount: 6)
      expect(reward_type.project).to eq(project)
    end
  end
end
