module Synchronisable
  extend ActiveSupport::Concern

  included do
    has_many :synchronisations, as: :synchronisable, dependent: :destroy

    def min_seconds_between_syncs
      synchronous_queue_adapter? ? 0 : 10
    end

    def max_seconds_in_pending
      60
    end

    def create_synchronisation
      Synchronisation.create(synchronisable_type: self.class.name, synchronisable_id: id)
    end

    def latest_synchronisation
      @latest_synchronisation ||= synchronisations.last
    end

    def sync_allowed?
      next_sync_allowed_after <= Time.current
    end

    def sync_in_progress?
      if latest_synchronisation.in_progress?
        if latest_synchronisation.created_at < max_seconds_in_pending.seconds.ago
          latest_synchronisation.failed!
          false
        else
          true
        end
      else
        false
      end
    end

    def failed_transactions_row
      latest_status, latest_status_row = synchronisations.pluck(:status).chunk(&:itself).to_a.last
      latest_status == 'failed' ? latest_status_row.size : 0
    end

    def next_sync_allowed_after(scale: :exponential)
      return Time.current unless latest_synchronisation
      return max_seconds_in_pending.seconds.from_now if sync_in_progress?
      return latest_synchronisation.updated_at + timeout if latest_synchronisation.ok?
      return latest_synchronisation.updated_at + timeout(scale) if latest_synchronisation.failed?
    end

    def timeout(scale = nil)
      case scale
      when :exponential
        min_seconds_between_syncs**failed_transactions_row
      when :linear
        min_seconds_between_syncs * failed_transactions_row
      else
        min_seconds_between_syncs
      end
    end

    private

      def synchronous_queue_adapter?
        ActiveJob::Base.queue_adapter.is_a?(ActiveJob::QueueAdapters::InlineAdapter)
      end
  end
end
