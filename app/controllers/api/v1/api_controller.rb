class Api::V1::ApiController < ActionController::Base
  include Rails::Pagination
  include Pundit

  rescue_from Pundit::NotAuthorizedError do
    head 401
  end

  def unavailable
    head 404
  end

  def current_domain
    [request.subdomains, request.domain].flatten.join('.')
  end

  def current_account
    @current_account ||= Account.find_by(id: session[:account_id])
  end

  alias current_user current_account

  def whitelabel_mission
    @whitelabel_mission ||= Mission.where(whitelabel: true).find_by(whitelabel_domain: current_domain)
  end

  def project_scope
    @project_scope ||= (whitelabel_mission ? whitelabel_mission.projects : Project.all)
  end

  private

    def nonce_unique?(nonce)
      key = "api::v1::nonce_history:#{whitelabel_mission.id}:#{nonce}"

      if Rails.cache.exist?(key)
        false
      else
        Rails.cache.write(key, true, expires_in: 1.day)
      end
    end
end
