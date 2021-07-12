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
        scope = AwardTypePolicy::Scope.new(project.account, project, nil, project.award_types).resolve

        expect(scope).to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end

    context 'project admin' do
      before do
        create(:project_role, project: project, account: project_admin, role: :admin)
      end

      it 'returns all award types' do
        scope = AwardTypePolicy::Scope.new(project_admin, project, nil, project.award_types).resolve

        expect(scope).to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end

    context 'contributor' do
      it 'doesnt return draft award_types' do
        scope = AwardTypePolicy::Scope.new(nil, project, nil, project.award_types).resolve

        expect(scope).not_to include(award_type_draft)
        expect(scope).to include(award_type_pending)
        expect(scope).to include(award_type_ready)
      end
    end

    describe '#index?' do
      context 'when whitelabel mission is present' do
        let(:whitelabel_mission) { create :whitelabel_mission, whitelabel_domain: 'www.example.com' }

        subject(:policy_scope) { AwardTypePolicy::Scope.new(project.account, project, whitelabel_mission, project.award_types) }

        context 'with hidden awards' do
          it { expect(policy_scope.index?).to eq(false) }
        end

        context 'with visible awards' do
          before { whitelabel_mission.update(project_awards_visible: true) }

          it { expect(policy_scope.index?).to eq(true) }
        end
      end

      context 'when whitelabel mission is blank' do
        subject(:policy_scope) { AwardTypePolicy::Scope.new(project.account, project, nil, project.award_types) }

        it { expect(policy_scope.index?).to eq(true) }
      end
    end
  end
end
