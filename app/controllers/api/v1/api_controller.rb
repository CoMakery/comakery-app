class Api::V1::ApiController < ActionController::Base
  include Rails::Pagination

  before_action :allow_only_whitelabel

  def allow_only_whitelabel
    unavailable unless whitelabel_mission
  end

  def unavailable
    head 404
  end

  def current_domain
    [request.subdomains, request.domain].flatten.join('.')
  end

  def whitelabel_mission
    @whitelabel_mission ||= Mission.where(whitelabel: true).find_by(whitelabel_domain: current_domain)
  end

  def project_scope
    @project_scope ||= (whitelabel_mission ? whitelabel_mission.projects : nil)
  end
end
