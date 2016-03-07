require 'rails_helper'

describe AwardType do
  describe "#validations" do
    it "requires many attributes" do
      award_type = AwardType.new
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to eq(["Project can't be blank", "Name can't be blank", "Amount can't be blank"])
    end
  end

  describe "associations" do
    let(:project) { create(:project, owner_account: create(:account)) }
    let(:award_type) { create(:award_type, project: project) }
    let(:award) { create(:award, award_type: award_type) }

    it "belongs to a project" do
      expect(award_type.project).to eq(project)
    end

    it "has many awards" do
      expect(award_type.awards).to match_array([award])
    end
  end
end
