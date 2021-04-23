namespace :balances do
  desc 'Sync all balances'
  task sync_all: :environment do
    SyncBalancesJob.perform_now
  end
end
