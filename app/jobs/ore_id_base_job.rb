class OreIdBaseJob < ApplicationJob
  private

    def reschedule(entity)
      self.class.set(wait: wait_to_perform(entity)).perform_later(entity.id)
    end

    def wait_to_perform(entity)
      return 0 if entity.next_sync_allowed_after.past?

      entity.next_sync_allowed_after - Time.current
    end
end
