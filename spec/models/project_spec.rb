require "rails_helper"

describe Project do
  describe "associations" do
    it "has many reward_types and accepts them as nested attributes" do
      project = Project.create!(reward_types_attributes: [{name: "Small reward", suggested_amount: "1000"}])

      expect(project.reward_types.count).to eq(1)
      expect(project.reward_types.first.name).to eq("Small reward")
      expect(project.reward_types.first.suggested_amount).to eq(1000)
    end
  end
end
