class GetSlackChannels
  include Interactor

  def call
    current_account = context.current_account

    response = current_account.slack.get_channels
    channels = response.channels
                   .reject { |channel| channel.is_archived }
                   .sort_by { |channel| -channel.num_members }
                   .map(&:name)

    context.channels = channels
  end
end