require 'rails_helper'

describe AwardType do
  describe 'associations' do
    let(:project) { create(:project, account: create(:account)) }
    let(:specialty) { create(:specialty) }
    let(:award_type) { create(:award_type, project: project, specialty: specialty) }
    let(:award) { create(:award, award_type: award_type) }

    it 'belongs to a project' do
      expect(award_type.project).to eq(project)
    end

    it 'has many awards' do
      expect(award_type.awards).to match_array([award])
    end

    it 'belongs to specialty' do
      expect(award_type.specialty).to eq(specialty)
    end
  end

  describe 'scopes' do
    describe '.matching_specialty_for(account)' do
      it 'returns award types matching with given account specialty or ones without defined specialty' do
        account = create(:account)
        2.times { create(:award_type).update!(specialty: nil) }
        3.times { create(:award_type, specialty: account.specialty) }
        4.times { create(:award_type) }
        scope = described_class.matching_specialty_for(account)
        expect(scope.count).to eq(5)
        expect(scope.where(specialty: nil).count).to eq(2)
        expect(scope.where(specialty: account.specialty).count).to eq(3)
      end
    end
  end

  describe 'validations' do
    it 'requires many attributes' do
      award_type = described_class.new
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to eq(["Project can't be blank"])
    end

    it 'cannot update specialty when having any awards in non-ready state' do
      award_type = create(:award_type)
      create(:award, award_type: award_type)
      award_type.update(specialty: create(:specialty))
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages.first).to include 'cannot be changed if batch has started tasks'
    end
  end
end
