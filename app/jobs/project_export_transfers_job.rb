class ProjectExportTransfersJob < ApplicationJob
  queue_as :default

  def perform(project_id, account_id)
    project = Project.find(project_id)
    account = Account.find(account_id)

    ProjectMailer.export_transfers(project, account).deliver_now
  end
end
