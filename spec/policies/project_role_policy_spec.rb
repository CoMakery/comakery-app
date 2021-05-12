require 'rails_helper'

describe ProjectRolePolicy do
  let!(:admin) { create(:account) }
  let!(:project) { create(:project, account: admin) }

  describe '#update?' do
    context 'updates project role' do
      context 'by user' do
        let!(:account) { create(:account) }
        let!(:project_role) { create(:project_role, project: project, account: account, role: :observer) }

        subject(:policy) { described_class.new(account, project_role) }

        it 'deny action' do
          expect(policy.update?).to be(false)
        end
      end

      context 'by admin' do
        context 'for project follower' do
          let!(:account) { create(:account) }
          let!(:project_role) { create(:project_role, project: project, account: account, role: :observer) }

          subject(:policy) { described_class.new(admin, project_role) }

          it 'authorize action' do
            expect(policy.update?).to be(true)
          end
        end

        context 'for own account' do
          let!(:project_role) { project.project_roles.find_by(account: admin) }

          subject(:policy) { described_class.new(admin, project_role) }

          it 'deny action' do
            expect(policy.update?).to be(false)
          end
        end
      end
    end
  end
end
