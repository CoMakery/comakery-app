class Swarmbot::Slack

  include ::Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  AVATAR = 'https://s3.amazonaws.com/swarmbot-production/spacekitty.jpg'

  def initialize(authentication)
    @client = ::Slack::Web::Client.new(
      token: authentication.slack_token,
      logger: Rails.logger
    )
  end

  def send_reward_notifications(reward:)
    text = %{
      Sweet! @#{reward.account.name}
      received #{pluralize(reward.reward_type.amount, "project coin")}
      for "#{reward.description}" in
      <#{project_url(reward.reward_type.project)}|#{reward.reward_type.project.title}>
    }.strip.gsub(/\s+/, ' ')

    message_response = @client.chat_postMessage(
      channel: '#bot-testing', # '#general', #
      text: text,
      as_user: false,       # don't post as *authed user*
      username: 'swarmbot', # post as swarmbot
      icon_url: AVATAR
    )

    reaction_response = @client.reactions_add(
      channel: message_response[:channel],         # must be channel ID, not #channel-name
      timestamp: message_response[:message][:ts],  # timestamp
      name: 'thumbsup'
    )

  end
end
