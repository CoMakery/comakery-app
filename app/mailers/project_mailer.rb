class ProjectMailer < ApplicationMailer
  def export_transfers(project, account)
    @project = project
    attach_transfers

    mail to: account.email, subject: 'Project Transfers'
  end

  private

    def attach_transfers
      attachments["project_transfers_#{@project.id}_#{Time.current.to_s.tr(' ', '_')}.csv"] = {
        mime_type: 'text/csv',
        content: @project.download_transfers_csv
      }
    end
end
