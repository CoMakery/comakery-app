class Comakery::Slack
  include ::Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  AVATAR = 'https://s3.amazonaws.com/comakery/spacekitty.jpg'.freeze

  def self.enabled?
    ENV['SLACK_API_KEY'].present? && ENV['SLACK_API_SECRET'].present?
  end

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
    text = AwardMessage.call(award: award).notifications_message
    message_response = @client.chat_postMessage(
      channel: '#' + award.channel.name,
      text: text,
      link_names: 1,            # make @user a live link and notify @user
      username: "#{I18n.t('project_name')} Bot",
      as_user: false,           # don't post as *authed user*
      icon_url: AVATAR
    )

    @client.reactions_add(
      channel: message_response[:channel], # must be channel ID, not #channel-name
      timestamp: message_response[:message][:ts],
      name: 'thumbsup'
    )
  end

  def get_users # rubocop:todo Naming/AccessorMethodName
    @client.users_list
  end

  def get_user_info(slack_user_id)
    @client.users_info(user: slack_user_id)
  end

  def fetch_channels
    @client.channels_list
  end
end
