module LoadTest
  module Sidekiq
    # rubocop:todo Rails/Output
    def self.perform(numder_of_jobs, sleep_for_each_job)
      p 'Start to schedule jobs...'
      numder_of_jobs.times do
        LoadTest::LoadTestJob.perform_later(sleep_for_each_job)
      end
      p 'All jobs was scheduled'
    end
  end

  class LoadTestJob < ApplicationJob
    retry_on StandardError, wait: :exponentially_longer, attempts: 3

    def perform(sleep_time)
      sleep sleep_time
      raise StandardError if rand(25).zero?
    end
  end
end
