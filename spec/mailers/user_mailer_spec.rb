require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#send_invite_to_platform' do
    let(:invite) { FactoryBot.create :invite }
    let(:project_role) { invite.invitable.reload }
    let(:mail) { UserMailer.send_invite_to_platform(project_role) }

    it 'renders the headers' do
      expect(mail.to).to eq([invite.email])
      expect(mail.subject).to eq("Invitation to #{project_role.project.title} on CoMakery")
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(%(
        You have been invited to have the role '#{project_role.role.capitalize}' for the project #{project_role.project.title} on CoMakery.
      ).squish)

      expect(mail.body.encoded).to match(%(
        To accept the invitation follow this
      ).squish)
    end
  end

  describe '#send_invite_to_project' do
    let(:project_role) { FactoryBot.create :project_role }
    let(:mail) { UserMailer.send_invite_to_project(project_role) }

    it 'renders the headers' do
      expect(mail.to).to eq([project_role.account.email])
      expect(mail.subject).to eq("Invitation to #{project_role.project.title} on CoMakery")
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(%(
        You now have the role '#{project_role.role.capitalize}' for the project #{project_role.project.title} on CoMakery.
      ).squish)
    end
  end
end
