require 'rails_helper'

RSpec.describe ProjectMailer, type: :mailer do
  describe 'export_transfers' do
    let(:project) { create(:project) }
    let(:mail) { ProjectMailer.export_transfers(project, project.account) }

    it 'renders the headers' do
      expect(mail.to).to eq([project.account.email])
      expect(mail.subject).to eq('Project Transfers')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('See attachment')
    end

    it 'includes attachment' do
      expect(mail.attachments.size).to eq(1)

      attachment = mail.attachments[0]

      expect(attachment.content_type).to start_with('text/csv')
      expect(attachment.filename).to match('project_transfers_')
    end
  end
end
