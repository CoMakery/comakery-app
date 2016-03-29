class Comakery::Slack

  include ::Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  AVATAR = 'https://s3.amazonaws.com/comakery/spacekitty.jpg'

  def self.get(token)
    new(token)
  end

  def initialize(token)
    @client = ::Slack::Web::Client.new(
      token: token,
      logger: Rails.logger
    )
  end

  def send_award_notifications(award:)
    text = %{
      @#{award.recipient_slack_user_name} received a
      #{award.award_type.amount} coin #{award.award_type.name}
      #{'for "' + award.description + '"' if award.description.present?}
      on the
      <#{project_url(award.award_type.project)}|#{award.award_type.project.title}>
      project.
    }.strip.gsub(/\s+/, ' ')

    message_response = @client.chat_postMessage(
      channel: '#'+award.award_type.project.slack_channel,
      text: text,
      link_names: 1,            # make @bob a live link and notify @bob
      username: 'CoMakery Bot',
      as_user: false,           # don't post as *authed user*
      icon_url: AVATAR
    )

    @client.reactions_add(
      channel: message_response[:channel],         # must be channel ID, not #channel-name
      timestamp: message_response[:message][:ts],
      name: 'thumbsup'
    )
  end

  def get_users
    @client.users_list
  end

  def get_user_info(slack_user_id)
    @client.users_info(user: slack_user_id)
  end

  def get_channels
    @client.channels_list
  end
end
