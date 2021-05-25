require 'rails_helper'

describe ProjectRolePolicy do
  let!(:owner) { create(:account) }
  let!(:project) { create(:project, account: owner) }
  let!(:project_role) { create(:project_role, project: project, account: owner, role: :admin) }

  describe '#update?' do
    context 'updates project account permissions' do
      context 'when account is nil' do
        let!(:account) { nil }
        let!(:project_role) { create(:project_role, project: project, role: :observer) }

        subject(:policy) { described_class.new(account, project_role) }

        it 'returns false' do
          expect(policy.update?).to be(false)
        end
      end

      context 'when the role is own' do
        let!(:project_role) { project.project_roles.find_by(account: owner) }

        subject(:policy) { described_class.new(owner, project_role) }

        it 'returns false' do
          expect(policy.update?).to be(false)
        end
      end

      context 'when the role is admin' do
        context 'when account is project owner' do
          let!(:project_role) { create(:project_role, project: project, role: :admin) }

          subject(:policy) { described_class.new(owner, project_role) }

          it 'returns true' do
            expect(policy.update?).to be(true)
          end
        end

        context 'when account is project admin' do
          let!(:account) { create(:account) }
          let!(:project_role) { create(:project_role, project: project, role: :admin) }

          before { create(:project_role, project: project, account: account, role: :admin) }

          subject(:policy) { described_class.new(account, project_role) }

          it 'returns false' do
            expect(policy.update?).to be(false)
          end
        end
      end

      context 'when the role is interested or observer' do
        context 'when account is project owner or admin' do
          let!(:project_role) { create(:project_role, project: project, role: :observer) }

          subject(:policy) { described_class.new(owner, project_role) }

          it 'returns true' do
            expect(policy.update?).to be(true)
          end
        end
      end
    end
  end
end
