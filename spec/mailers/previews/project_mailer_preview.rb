# Preview all emails at http://localhost:3000/rails/mailers/project_mailer
class ProjectMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/project_mailer/export_transfers
  def export_transfers
    ProjectMailer.export_transfers(Project.first, Account.first)
  end
end
