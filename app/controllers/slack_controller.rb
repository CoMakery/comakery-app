class SlackController < ApplicationController
  skip_before_action :require_login
  before_action :skip_authorization
  protect_from_forgery with: :null_session

  layout 'legacy'

  def command(*_args)
    render json: {
      response_type: 'in_channel',
      attachments: [
        {
          text: %( Hi! #{I18n.t('project_name')} helps you share revenue with product teams.
            For more intel, drop by https://#{ENV['APP_HOST']}
          ).strip.gsub(/\s+/, ' ')
        }
      ]
    }
  end
end
