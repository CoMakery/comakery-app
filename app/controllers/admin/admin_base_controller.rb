class Admin::AdminBaseController < ApplicationController
  before_action :require_admin

  layout 'admin'
end
