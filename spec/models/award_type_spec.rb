require 'rails_helper'

describe AwardType do
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

  describe 'validations' do
    it 'requires many attributes' do
      award_type = described_class.new
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to eq(["Project can't be blank"])
    end
  end

  describe 'switch_tasks_publicity' do
    let!(:award_type_published) { create(:award_type, published: true) }
    let!(:award_published) { create(:award_ready, award_type: award_type_published) }
    let!(:award_type_unpublished) { create(:award_type, published: false) }
    let!(:award_unpublished) { create(:award, award_type: award_type_unpublished, status: :unpublished) }

    it 'switches ready awards to unpublished if published? changed to false' do
      award_published.update(account: nil)
      award_type_published.update(published: false)
      expect(award_published.reload.unpublished?).to be_truthy
    end

    it 'switches unpublished awards to ready if published? changed to true' do
      award_type_unpublished.update(published: true)
      expect(award_unpublished.reload.ready?).to be_truthy
    end
  end
end
