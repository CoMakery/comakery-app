require 'rails_helper'

RSpec.describe ProjectExportTransfersJob, type: :job do
  let!(:project) { create(:project) }

  subject { described_class.perform_now(project.id, project.account.id) }

  specify do
    expect(ProjectMailer).to receive_message_chain(:export_transfers, :deliver_now).with(project, project.account).with(no_args)

    subject
  end
end
