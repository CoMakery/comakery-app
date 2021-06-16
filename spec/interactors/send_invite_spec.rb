require 'rails_helper'

describe SendInvite do
  describe '#call' do
    let!(:project) { create(:project) }
    let!(:whitelabel_mission) { create(:whitelabel_mission) }

    context 'when account is not registered' do
      let(:params) { { email: 'unregistered@gmail.com', role: :interested } }

      context 'and email is valid' do
        context 'when the invite has already been sent to the user' do
          let!(:invite) { FactoryBot.create(:invite, email: params[:email], invitable: project) }

          subject(:result) do
            described_class.call(params: params, whitelabel_mission: whitelabel_mission, project: project)
          end

          it { expect(result.errors).to eq(['Invite is already sent']) }

          it { expect(result.success?).to be(false) }
        end

        context 'when the invite has not yet been sent to the user' do
          subject(:result) do
            described_class.call(params: params, whitelabel_mission: whitelabel_mission, project: project)
          end

          it { expect { result }.to change { UserMailer.deliveries.count }.by(1) }

          it { expect(result.success?).to be(true) }
        end
      end

      context 'and email is not valid' do
        let(:params) { { email: 'invalid', role: :interested } }

        subject(:result) do
          described_class.call(params: params, whitelabel_mission: whitelabel_mission, project: project)
        end

        it { expect(result.errors).to eq(['Email is invalid']) }

        it { expect(result.success?).to be(false) }
      end
    end

    context 'when account is registered' do
      let(:account) { create(:account, managed_mission: whitelabel_mission) }

      context 'and involved to project' do
        let(:project_role) { create(:project_role, project: project, account: account, role: :admin) }
        let(:params) { { email: project_role.account.email, role: :interested } }

        subject(:result) do
          described_class.call(params: params, whitelabel_mission: whitelabel_mission, project: project)
        end

        it {
          expect(result.errors).to eq(["User already has #{project_role.role} permissions for this project. " \
                                          'You can update their role with the action menu on this Accounts page'])
        }

        it { expect(result.success?).to be(false) }
      end

      context 'and not involved to project' do
        let(:params) { { email: account.email, role: :interested } }

        subject(:result) do
          described_class.call(params: params, whitelabel_mission: whitelabel_mission, project: project)
        end

        it { expect { result }.to change(ProjectRole, :count).by(1) }

        it { expect { result }.to change { UserMailer.deliveries.count }.by(1) }

        it { expect(result.success?).to be(true) }
      end
    end
  end
end
