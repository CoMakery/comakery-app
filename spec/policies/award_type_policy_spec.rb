require 'rails_helper'

describe AwardTypePolicy do
  let!(:project) { create(:project) }
  let!(:award_type_draft) { create(:award_type, project: project, state: :draft) }
  let!(:award_type_pending) { create(:award_type, project: project, state: :pending) }
  let!(:award_type_ready) { create(:award_type, project: project, state: :ready) }

  describe AwardTypePolicy::Scope do
    context 'project owner' do
      it 'returns all award types' do
        scope = AwardTypePolicy::Scope.new(project.account, project.account, project.award_types).resolve

        expect(scope).to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end

    context 'not project owner' do
      it 'doesnt return draft award_types' do
        scope = AwardTypePolicy::Scope.new(nil, project.account, project.award_types).resolve

        expect(scope).not_to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end
  end
end
