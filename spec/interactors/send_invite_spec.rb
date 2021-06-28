require 'rails_helper'

describe SendInvite do
  describe '#call' do
    let!(:project) { create(:project) }
    let!(:whitelabel_mission) { create(:whitelabel_mission) }

    subject do
      described_class.call(params: params, whitelabel_mission: whitelabel_mission, project: project)
    end

    context 'when email is not valid' do
      let(:params) { { email: 'invalid', role: :interested } }

      it { is_expected.not_to be_success }

      specify do
        expect(subject.errors).to eq(['Email is invalid'])
      end
    end

    context 'when account is not registered' do
      let(:params) { { email: 'unregistered@gmail.com', role: :interested } }

      it { is_expected.to be_success }

      specify do
        expect { subject }.to change { UserMailer.deliveries.count }.by(1)
      end

      specify do
        expect { subject }.to change { ProjectRole.count }.by(1)
        expect(project.project_roles.last.account).to be_nil
        expect(project.project_roles.last.role).to eq('interested')
      end

      specify do
        expect { subject }.to change { Invite.pending.count }.by(1)
      end
    end

    context 'when account is registered' do
      let(:account) { create(:account, managed_mission: whitelabel_mission) }

      context 'and has a project role' do
        let(:project_role) { create(:project_role, project: project, account: account, role: :admin) }
        let(:params) { { email: project_role.account.email, role: :interested } }

        it { is_expected.not_to be_success }

        specify do
          expect(subject.errors).to eq(['Account already has a role in project'])
        end
      end

      context 'and doesnt have a project role' do
        let(:params) { { email: account.email, role: :interested } }

        it { is_expected.to be_success }

        specify do
          expect { subject }.to change { UserMailer.deliveries.count }.by(1)
        end

        specify do
          expect { subject }.to change { ProjectRole.count }.by(1)
          expect(project.project_roles.last.account).to eq(account)
          expect(project.project_roles.last.role).to eq('interested')
        end
      end
    end
  end
end
