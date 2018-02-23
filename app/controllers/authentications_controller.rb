class AuthenticationsController < ApplicationController
  skip_after_action :verify_authorized, only: [:show]

  def show
    @current_user = current_user
    @authentication = @current_user.slack_auth
    @awards = @current_user.slack_awards.includes(award_type: :project).decorate
  end
end
