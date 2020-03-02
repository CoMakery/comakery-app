module Blockchain
  class BlockchainTransactionSyncJob < ApplicationJob
    queue_as :default

    def perform(record)
      @record = record

      return unless @record.pending?
      return reschedule if @record.waiting_till_next_sync_is_allowed?
      return reschedule unless @record.sync
    end

    private

      def reschedule
        self.class.set(wait: 1.minute).perform_later(@record)
      end
  end
end
