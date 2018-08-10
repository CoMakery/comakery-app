class GetSlackChannels
  include Interactor

  def call
    authentication_team = context.authentication_team
    begin
      response = authentication_team.slack.fetch_channels
      channels = response.channels
                         .reject(&:is_archived)
                         .sort_by { |channel| channel['name'] }
                         .map(&:name)

      context.channels = channels
    rescue Slack::Web::Api::Error => e
      context.fail!(message: "Slack API error - #{e}")
    end
  end
end
