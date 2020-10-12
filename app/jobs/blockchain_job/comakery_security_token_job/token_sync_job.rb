module BlockchainJob
  module ComakerySecurityTokenJob
    class TokenSyncJob < BlockchainJob::ComakerySecurityTokenJob::SyncJob
      def sync
        @record.token_frozen = @contract.isPaused

        sync_accounts
      end

      def sync_accounts
        @record.accounts.distinct.each do |account|
          record = @token.account_token_records.find_or_create_by(account: account)
          BlockchainJob::ComakerySecurityTokenJob::AccountSyncJob.perform_later(record)
        end
      end
    end
  end
end
