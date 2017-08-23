class Admin::AdminController < Admin::AdminBaseController
  skip_after_action :verify_policy_scoped

  def index; end
end
