class TransfersExporterJob < ApplicationJob
  queue_as :default

  def perform(project_id, account_id)
    project = Project.find(project_id)
    account = Account.find(account_id)
    TransfersExporter.new(project, account).save_transfers_csv
  end
end
