require 'rails_helper'

describe RewardType do
  describe "#validations" do
    it "requires many attributes" do
      reward_type = RewardType.new
      expect(reward_type).not_to be_valid
      expect(reward_type.errors.full_messages).to eq(["Project can't be blank", "Name can't be blank", "Amount can't be blank"])
    end
  end

  describe "associations" do
    let(:project) { create(:project, owner_account: create(:account)) }
    let(:reward_type) { create(:reward_type, project: project) }
    let(:reward) { create(:reward, reward_type: reward_type) }

    it "belongs to a project" do
      expect(reward_type.project).to eq(project)
    end

    it "has many rewards" do
      expect(reward_type.rewards).to match_array([reward])
    end
  end
end
