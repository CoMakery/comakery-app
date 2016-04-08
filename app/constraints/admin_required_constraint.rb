class AdminRequiredConstraint
  def matches?(request)
    user = current_user(request)
    ApplicationPolicy.new(user, nil).admin?
  end

  private

  def current_user(request)
    Account.find_by_id(request.session[:user_id])
  end
end
