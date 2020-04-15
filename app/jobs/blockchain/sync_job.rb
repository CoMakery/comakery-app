module Blockchain
  class SyncJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      comakery_security_tokens
      pending_blockchain_transactions
    end

    private

      def comakery_security_tokens
        Token.coin_type_comakery.each do |token|
          Blockchain::ComakerySecurityToken::TokenSyncJob.perform_later(token)
        end
      end

      def pending_blockchain_transactions
        BlockchainTransaction.pending.each do |transaction|
          Blockchain::BlockchainTransactionSyncJob.perform_later(transaction)
        end
      end
  end
end
