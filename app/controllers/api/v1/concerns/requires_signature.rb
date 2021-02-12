module Api::V1::Concerns::RequiresSignature
  extend ActiveSupport::Concern
  include Api::V1::Concerns::LogRequest

  included do
    before_action :verify_signature

    def verify_signature
      signature_verification_result =
        Comakery::APISignature.new(
          params.as_json,
          request.base_url + request.path,
          request.method,
          ->(nonce) { nonce_unique?(nonce) }
        ).verify(whitelabel_mission&.whitelabel_api_public_key)

      log_request(params.to_unsafe_h, request.ip) if signature_verification_result
      signature_verification_result
    rescue Comakery::APISignatureError => e
      @errors = { authentication: e.message }

      render 'api/v1/error.json', status: :unauthorized, layout: false
    end

    def nonce_unique?(nonce)
      key = "api::v1::nonce_history:#{whitelabel_mission.id}:#{nonce}"

      if Rails.cache.exist?(key)
        false
      else
        cache_expiration = Comakery::APISignature::TIMESTAMP_EXPIRATION_SECONDS.seconds
        CacheExtension.cache_write!(key, true, expires_in: cache_expiration)
      end
    end
  end
end
