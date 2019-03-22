require 'rails_helper'

describe AwardType do
  # TODO: Uncomment when implemented
  # it { is_expected.to belong_to(:specialty) }

  describe '#validations' do
    it 'requires many attributes' do
      award_type = described_class.new
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to eq(["Project can't be blank", "Specialty can't be blank"])
    end
  end

  describe 'associations' do
    let(:project) { create(:project, account: create(:account)) }
    let(:award_type) { create(:award_type, project: project) }
    let(:award) { create(:award, award_type: award_type) }

    it 'belongs to a project' do
      expect(award_type.project).to eq(project)
    end

    it 'has many awards' do
      expect(award_type.awards).to match_array([award])
    end
  end
end
