namespace :blockchain_sync do
  desc 'Add blockchain sync job to Sidekiq queue'
  task perform: :environment do
    BlockchainJob::SyncJob.perform_later
  end
end
