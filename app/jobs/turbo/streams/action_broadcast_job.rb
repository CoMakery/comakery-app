# https://github.com/hotwired/turbo-rails/blob/main/app/jobs/turbo/streams/action_broadcast_job.rb

# The job that powers all the <tt>broadcast_$action_later</tt> broadcasts available in <tt>Turbo::Streams::Broadcasts</tt>.
class Turbo::Streams::ActionBroadcastJob < ApplicationJob
  def perform(stream, action:, target:, **rendering)
    rendering[:locals]&.transform_values! do |v|
      v.decorate
    rescue Draper::UninferrableDecoratorError, NoMethodError
      v
    end

    Turbo::StreamsChannel.broadcast_action_to stream, action: action, target: target, **rendering
  end
end
