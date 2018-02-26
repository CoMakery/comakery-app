class PasswordResetsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[new create]

  def new; end
end
