class Swarmbot::Slack

  include ::Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  AVATAR = 'https://s3.amazonaws.com/swarmbot-production/spacekitty.jpg'

  def self.get(token)
    new(token)
  end

  def initialize(token)
    @client = ::Slack::Web::Client.new(
      token: token,
      logger: Rails.logger
    )
  end

  def send_reward_notifications(reward:)
    text = %{
      #{reward.recipient_slack_user_name} received a
      #{reward.reward_type.amount} coin #{reward.reward_type.name}
      #{'for "' + reward.description + '"' if reward.description.present?}
      on the
      <#{project_url(reward.reward_type.project)}|#{reward.reward_type.project.title}>
      project.
    }.strip.gsub(/\s+/, ' ')

    message_response = @client.chat_postMessage(
      channel: '#bot-testing', # '#general', #
      text: text,
      as_user: false,       # don't post as *authed user*
      username: 'swarmbot', # post as swarmbot
      icon_url: AVATAR
    )

    @client.reactions_add(
      channel: message_response[:channel],         # must be channel ID, not #channel-name
      timestamp: message_response[:message][:ts],  # timestamp
      name: 'thumbsup'
    )
  end

  def get_users
    @client.users_list.members
  end

  def get_user_info(slack_user_id)
    @client.users_info(user: slack_user_id).user
  end
end
