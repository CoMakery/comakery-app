module LoadTest
  module Sidekiq
    def self.perform(numder_of_jobs, sleep_for_each_job)
      p 'Start to schedule jobs...'
      numder_of_jobs.times do
        LoadTest::LoadTestJob.perform_later(sleep_for_each_job)
      end
      p 'All jobs was scheduled'
    end
  end

  class LoadTestJob < ApplicationJob
    def perform(sleep_time)
      sleep sleep_time
    end
  end
end
