module LoadTest
  module Sidekiq
    # rubocop:todo Rails/Output
    def self.perform(numder_of_jobs, sleep_for_each_job, percent_of_failures = 0)
      p 'Start to schedule jobs...'
      numder_of_jobs.times do
        LoadTest::LoadTestJob.perform_later(sleep_for_each_job, percent_of_failures)
      end
      p 'All jobs was scheduled'
    end
  end

  class LoadTestJob < ApplicationJob
    retry_on StandardError, wait: :exponentially_longer, attempts: 3

    def perform(sleep_time, percent_of_failures)
      sleep sleep_time
      raise StandardError if rand(100) <= percent_of_failures - 1
    end
  end
end
