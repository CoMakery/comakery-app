module Swarmbot
  class Slack

    include ::Rails.application.routes.url_helpers

    AVATAR = 'https://s3.amazonaws.com/swarmbot-production/spacekitty.jpg'

    def initialize(authentication)
      @client = ::Slack::Web::Client.new token: authentication.slack_token
    end

    def send_reward_notifications(project:, reward:)
      text = %{
        Sweet! @#{reward.account.name}
        received #{reward.amount} project coins
        for "#{reward.description}"!
        For more intel on #{reward.project.title},
        see #{project_url(reward.project)}
      }.strip.gsub(/\s+/, ' ')

      @client.chat_postMessage(
        channel: '#general',
        text: text,
        as_user: false,       # don't post as *authed user*
        username: 'swarmbot', # post as swarmbot
        icon_url: AVATAR
      )
    end
  end
end
