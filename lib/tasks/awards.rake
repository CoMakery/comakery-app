namespace :awards do
  desc 'Process all expired awards'
  task expire: :environment do
    Award.started.where(expires_at: Time.zone.at(0)..Time.current).each(&:touch)

    Award.started.where(notify_on_expiration_at: Time.zone.at(0)..Time.current).each do |expiring_award|
      TaskMailer.with(award: expiring_award).task_expiring.deliver_now
      expiring_award.expiring_notification_sent
    end
  end
end
