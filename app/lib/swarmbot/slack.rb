class Swarmbot::Slack

  include ::Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  AVATAR = 'https://s3.amazonaws.com/swarmbot-production/spacekitty.jpg'

  def initialize(authentication)
    @client = ::Slack::Web::Client.new token: authentication.slack_token
  end

  def send_reward_notifications(project:, reward:)
    text = %{
      Sweet! @#{reward.account.name}
      received #{pluralize(reward.amount, "project coin")}
      for "#{reward.description}" in
      <#{project_url(reward.project)}|#{reward.project.title}>
    }.strip.gsub(/\s+/, ' ')

    @client.chat_postMessage(
      channel: '#general', # '#bot-testing',
      text: text,
      as_user: false,       # don't post as *authed user*
      username: 'swarmbot', # post as swarmbot
      icon_url: AVATAR
    )
  end
end
