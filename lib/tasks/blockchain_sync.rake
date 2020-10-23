namespace :blockchain_sync do
  desc 'Add blockchain sync job to Sidekiq queue'
  task perform: :environment do
    BlockchainJob::SyncJob.perform_later
  end

  desc 'Add blockchain sync for transfer rules to Sidekiq queue'
  task transfer_rules: :environment do
    Token._token_type_comakery_security_token.each do |token|
      BlockchainJob::ComakerySecurityTokenJob::TransferRulesSyncJob.perform_later(token)
    end
  end
end
