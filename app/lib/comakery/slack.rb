class Comakery::Slack
  include ::Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  AVATAR = 'https://s3.amazonaws.com/comakery/spacekitty.jpg'.freeze

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
    text = award_notifications_message(award)

    message_response = @client.chat_postMessage(
      channel: '#' + award.project.slack_channel,
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

  # rubocop:disable Metrics/CyclomaticComplexity
  def award_notifications_message(award)
    text = ''

    text += if award.self_issued?
      %( @#{award.issuer_slack_user_name} self-issued )
    else
      %( @#{award.issuer_slack_user_name} sent
        @#{award.recipient_slack_user_name} )
    end

    text += %( a #{award.total_amount} token #{award.award_type.name} )

    text += %( for "#{award.description}" ) if award.description.present?

    text += %(
      on the
      <#{project_url(award.project)}|#{award.project.title}>
      project.
    )

    if award.project.ethereum_enabled && award.recipient_address.blank?
      text += " <#{account_url}|Set up your account> to receive Ethereum tokens."
    end

    text.strip!.gsub!(/\s+/, ' ')
    text
  end

  def get_users
    @client.users_list
  rescue Faraday::ConnectionFailed => e
    if Rails.env.development?
      { members: [] }
    else
      raise e
    end
  end

  def get_user_info(slack_user_id)
    @client.users_info(user: slack_user_id)
  end

  def get_channels
    @client.channels_list
  end
end
