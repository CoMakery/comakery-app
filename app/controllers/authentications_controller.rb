class AuthenticationsController < ApplicationController
  def show
    @current_user = current_user
    @authentication = @current_user.slack_auth
    @awards = @current_user.awards.includes(award_type: :project).decorate
  end
end
