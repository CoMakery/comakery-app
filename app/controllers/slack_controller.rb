class SlackController < ApplicationController
  skip_before_filter :require_login
  before_filter :skip_authorization
  protect_from_forgery with: :null_session

  def command *args
  #   d proc { args }
    render json: {
      response_type: "in_channel",
      attachments: [
        {
        text: %{ Hi!  Swarmbot helps you share equity with your team.
          For more intel, drop by #{request.protocol}#{request.host_with_port}
          }.strip.gsub(/\s{2,}/, ' ')
        }
      ]
    }
  end


  # def debug
  #
  #   slack_auth = current_account.slack_auth
  #
  #   client = Slack::Web::Client.new(
  #     token: slack_auth.slack_token
  #     # endpoint: slack_auth.web_hook_url
  #   )
  #   p 1, client.auth_test
  #
  #   p 2, client.chat_postMessage(
  #     channel: "#bot-testing", # slack_auth.web_hook_channel_id,
  #     text: 'Random purrr',
  #     as_user: false,        # don't post as *authed user*
  #     username: 'swarmbot'  # post as swarmbot
  #     # icon_url: asset_url (...)
  #   )
  #
  #   p 3, client.chat_postMessage(
  #     channel: "@harlan",
  #     text: 'Meow',
  #     as_user: false,        # don't post as *authed user*
  #     username: 'swarmbot'  # post as swarmbot
  #     # icon_url: asset_url (...)
  #   )
  # end
end
