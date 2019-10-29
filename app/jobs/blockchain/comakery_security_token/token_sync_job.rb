module Blockchain
  module ComakerySecurityToken
    class TokenSyncJob < Blockchain::ComakerySecurityToken::SyncJob
      def sync
        @record.token_frozen = @contract.isPaused

        sync_accounts
      end

      def sync_accounts
        @record.accounts.distinct.where.not(ethereum_wallet: nil).each do |account|
          record = @token.account_token_records.find_or_create_by(account: account)
          Blockchain::ComakerySecurityToken::AccountSyncJob.perform_later(record)
        end
      end
    end
  end
end
