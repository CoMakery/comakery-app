class PagesController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized
end
