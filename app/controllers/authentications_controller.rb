class AuthenticationsController < ApplicationController
  skip_after_action :verify_authorized, only: [:show]

  def show
    @authentication = current_user.slack_auth
    @awards = @authentication.awards.includes(award_type: :project)
  end
end