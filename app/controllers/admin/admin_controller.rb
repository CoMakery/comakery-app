class Admin::AdminController < Admin::AdminBaseController
  skip_after_filter :verify_policy_scoped

  def index
  end
end
