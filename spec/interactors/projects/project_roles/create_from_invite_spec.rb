require 'rails_helper'

describe Projects::ProjectRoles::CreateFromInvite do
  let!(:project) { create(:project) }
  let(:account) { create(:account, email: 'example@gmail.com') }
  let(:invite) { FactoryBot.create(:invite, invitable: project, email: 'example@gmail.com') }

  context 'when invite is pending' do
    subject(:result) { described_class.call(account: account, project_invite: invite) }

    it 'accepts invite' do
      result

      expect(invite.reload.accepted?).to eq(true)
    end

    it { expect { result }.to change(ProjectRole, :count).by(1) }

    it { expect(result.success?).to be(true) }
  end

  context 'when invite is blank' do
    subject(:result) { described_class.call(account: account, project_invite: nil) }

    it { expect { result }.not_to change(ProjectRole, :count).from(1) }

    it { expect(result.success?).to be(true) }
  end
end
