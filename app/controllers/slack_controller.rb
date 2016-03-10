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
        text: %{ Hi! CoMakery helps you share equity with your team.
          For more intel, drop by #{request.protocol}#{request.host_with_port}
        }.strip.gsub(/\s+/, ' ')
        }
      ]
    }
  end
end
