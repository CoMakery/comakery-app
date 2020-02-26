module Blockchain
  class BlockchainTransactionSyncJob < ApplicationJob
    queue_as :default

    def perform(record)
      reschedule unless record.sync
    end

    private

      def reschedule
        self.class.set(wait: 1.minute).perform_later
      end
  end
end
