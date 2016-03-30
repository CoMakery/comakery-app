class GetSlackChannels
  include Interactor

  def call
    current_account = context.current_account

    begin
      response = current_account.slack.get_channels
      channels = response.channels
                         .reject { |channel| channel.is_archived }
                         .sort_by { |channel| channel["name"] }
                         .map(&:name)

      context.channels = channels
    rescue Slack::Web::Api::Error => e
      context.fail!(message: "Slack API error - #{e}")
    end
  end
end