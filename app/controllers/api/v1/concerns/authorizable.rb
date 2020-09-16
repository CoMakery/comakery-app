module Api::V1::Concerns::Authorizable
  extend ActiveSupport::Concern

  def authorized
    @authorized
  end

  def authorize!
    @authorized = true
  end
end
