require 'rails_helper'

describe AwardTypePolicy do
  let!(:project) { create(:project) }
  let!(:project_admin) { create(:account) }
  let!(:award_type_draft) { create(:award_type, project: project, state: 'draft') }
  let!(:award_type_pending) { create(:award_type, project: project, state: 'invite only') }
  let!(:award_type_ready) { create(:award_type, project: project, state: 'public') }

  describe AwardTypePolicy::Scope do
    context 'project owner' do
      it 'returns all award types' do
        scope = AwardTypePolicy::Scope.new(project.account, project, project.award_types).resolve

        expect(scope).to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end

    context 'project admin' do
      before do
        project.admins << project_admin
      end

      it 'returns all award types' do
        scope = AwardTypePolicy::Scope.new(project_admin, project, project.award_types).resolve

        expect(scope).to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end

    context 'contributor' do
      it 'doesnt return draft award_types' do
        scope = AwardTypePolicy::Scope.new(nil, project, project.award_types).resolve

        expect(scope).not_to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end
  end
end
