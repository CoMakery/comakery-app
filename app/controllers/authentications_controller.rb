class AuthenticationsController < ApplicationController
  skip_after_action :verify_authorized, only: [:show]

  def show
    @current_user = current_user
    @authentication = @current_user.slack_auth
    @awards = @authentication.awards.includes(award_type: :project)
  end
end