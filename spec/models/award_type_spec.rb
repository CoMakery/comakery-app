# == Schema Information
#
# Table name: award_types
#
#  amount              :integer          not null
#  community_awardable :boolean          default("false"), not null
#  created_at          :datetime         not null
#  id                  :integer          not null, primary key
#  name                :string           not null
#  project_id          :integer          not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

describe AwardType do
  describe "#validations" do
    it "requires many attributes" do
      award_type = AwardType.new
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to eq(["Project can't be blank", "Name can't be blank", "Amount can't be blank"])
    end

    it "prevents modification of amount if there are existing awards" do
      award_type = create(:award).award_type
      award_type.amount += 1000
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to be_include("Amount can't be modified if there are existing awards")
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

  describe "scopes" do
    describe "#modifiable?" do
      it "returns true if there are awards" do
        award_type = create(:award_type)
        expect(award_type).to be_modifiable

        create(:award, award_type: award_type)
        expect(award_type).not_to be_modifiable
      end
    end
  end
end
