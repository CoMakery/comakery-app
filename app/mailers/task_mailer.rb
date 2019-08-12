class TaskMailer < ApplicationMailer
  before_action :set_params
  after_action :send_email

  helper SignatureHelper

  layout 'task_mailer'

  default to: -> { @to }, subject: -> { @subject }

  def task_assigned
    @to = @account.email
    @subject = "Congrats! You've been assigned a task."
  end

  def task_paid
    @to = @account.email
    @subject = "You've been paid!"
  end

  def task_rejected
    @to = @account.email
    @subject = 'A task was not accepted'
  end

  def task_submitted
    @to = @issuer.email
    @subject = "Work has been submitted - #{@award.name} is ready for your review"
  end

  def task_accepted
    @to = @account.email
    @subject = "Good news. #{@award.name} has been accepted by the project owner"
  end

  def task_accepted_direct
    @to = @account&.email || @email
    @subject = "Incoming Award: #{@award.project.title}"
  end

  def task_expiring
    @to = @account.email
    @subject = 'Your task is going to expire'
  end

  def task_expired_for_account
    @to = @account.email
    @subject = 'Your task has expired'
  end

  def task_expired_for_issuer
    @to = @issuer.email
    @subject = "A #{@award.project.title} task has expired"
  end

  private

    def set_params
      @award   = params[:award]
      @issuer  = @award.issuer&.decorate
      @account = @award.account&.decorate
      @email   = @award.email
    end

    def send_email
      mail

      mail.perform_deliveries = false if Unsubscription.exists?(email: @to)
    end
end
