namespace :awards do
  desc 'Process all expired awards'
  task expire: :environment do
    Award.started.where(expires_at: Time.zone.at(0)..Time.current).each do |expired_award|
      TaskMailer.with(award: expired_award).task_expired_for_account.deliver_now
      TaskMailer.with(award: expired_award).task_expired_for_issuer.deliver_now
      expired_award.expire!
    end

    Award.started.where(notify_on_expiration_at: Time.zone.at(0)..Time.current).each do |expiring_award|
      TaskMailer.with(award: expiring_award).task_expiring.deliver_now
    end
  end
end
