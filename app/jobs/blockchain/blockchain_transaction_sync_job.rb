module Blockchain
  class BlockchainTransactionSyncJob < ApplicationJob
    queue_as :default

    def perform(record)
      @record = record

      return unless @record.pending?
      reschedule unless @record.sync
    end

    private

      def reschedule
        self.class.set(wait: 1.minute).perform_later(@record)
      end
  end
end
