namespace :awards do
  desc 'Process all expired awards'
  task expire: :environment do
    Award.started.where(expires_at: Time.zone.at(0)..Time.current).each(&:run_expiration)
    Award.started.where(notify_on_expiration_at: Time.zone.at(0)..Time.current).each(&:run_expiring_notification)
  end
end
