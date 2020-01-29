class Api::V1::ApiController < ActionController::Base
  include Rails::Pagination

  before_action :allow_only_whitelabel
  before_action :verify_public_key
  before_action :verify_signature

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

  def verify_public_key
    if @whitelabel_mission.whitelabel_api_key != request.headers['API-Key']
      @errors = { authentication: 'Invalid API key' }

      render 'api/v1/error.json', status: 401
    end
  end

  def verify_signature
    Comakery::APISignature.new(
      params.as_json,
      request.base_url + request.path,
      request.method,
      ->(nonce) { nonce_unique?(nonce) }
    ).verify(@whitelabel_mission.whitelabel_api_public_key)
  rescue Comakery::APISignatureError => e
    @errors = { authentication: e.message }

    return render 'api/v1/error.json', status: 401
  end

  private

    def nonce_unique?(nonce)
      key = "api::v1::nonce_history:#{@whitelabel_mission.id}:#{nonce}"

      if Rails.cache.exist?(key)
        false
      else
        Rails.cache.write(key, true, expires_in: 1.day)
      end
    end
end
