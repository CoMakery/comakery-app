class PasswordResetsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: [:new, :create]

  def new

  end
end
