class TaskMailerPreview < ActionMailer::Preview
  def task_assigned
    TaskMailer.with(award: Award.started.sample).task_assigned
  end

  def task_paid
    TaskMailer.with(award: Award.paid.sample).task_paid
  end

  def task_rejected
    TaskMailer.with(award: Award.rejected.sample).task_rejected
  end

  def task_submitted
    TaskMailer.with(award: Award.submitted.sample).task_submitted
  end

  def task_accepted
    TaskMailer.with(award: Award.accepted.sample).task_accepted
  end

  def task_accepted_direct
    TaskMailer.with(award: Award.accepted.sample).task_accepted_direct
  end

  def task_accepted_direct_new_user
    TaskMailer.with(award: Award.accepted.where(account: nil).sample).task_accepted_direct
  end

  def task_expiring
    TaskMailer.with(award: Award.started.where.not(expires_at: nil).sample).task_expiring
  end

  def task_expired_for_account
    TaskMailer.with(award: Award.started.sample).task_expired_for_account
  end

  def task_expired_for_issuer
    TaskMailer.with(award: Award.started.sample).task_expired_for_issuer
  end
end
