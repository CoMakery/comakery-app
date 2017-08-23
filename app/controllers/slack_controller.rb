class SlackController < ApplicationController
  skip_before_action :require_login
  before_action :skip_authorization
  protect_from_forgery with: :null_session

  def command(*_args)
    #   d proc { args }
    render json: {
      response_type: 'in_channel',
      attachments: [
        {
          text: %( Hi! CoMakery helps you share revenue with product teams.
            For more intel, drop by #{ENV['APP_HOST']}
          ).strip.gsub(/\s+/, ' ')
        }
      ]
    }
  end
end
